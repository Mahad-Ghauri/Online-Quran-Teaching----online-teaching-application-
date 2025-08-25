// Unified Authentication service for QariConnect app
// Handles Firebase Auth operations and user session management

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/core_models.dart';
import 'firestore_service.dart';

class AuthService {
  // Singleton pattern for backward compatibility
  AuthService._();
  static final AuthService instance = AuthService._();
  
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // SharedPreferences keys
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userRoleKey = 'user_role';
  static const String _userIdKey = 'user_id';

  /// Get current Firebase user
  static User? get currentUser => _auth.currentUser;
  User? get currentUserInstance => _auth.currentUser; // For instance access

  /// Get current user stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  Stream<User?> getAuthStateChanges() => _auth.authStateChanges(); // For instance access

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    return isLoggedIn && currentUser != null;
  }

  /// Get stored user role
  static Future<UserRole?> getStoredUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString(_userRoleKey);
    if (roleString != null) {
      return UserRole.values.firstWhere(
        (role) => role.name == roleString,
        orElse: () => UserRole.student,
      );
    }
    return null;
  }

  /// Get stored user ID
  static Future<String?> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Sign up with email and password (New style - returns UserModel)
  static Future<UserModel> signUpWithModel({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    try {
      // Create Firebase Auth user
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user account');
      }

      // Update display name
      await userCredential.user!.updateDisplayName(name);

      // Create user profile in Firestore with all required fields
      final userModel = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        isVerified: false, // Default to false, admin must verify Qaris
        createdAt: DateTime.now(),
      );

      await FirestoreService.createUserProfile(userModel);
      await _storeLoginState(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign up with legacy parameters (Old style - for backward compatibility)
  Future<User?> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role, // "Student" or "Qari" as string
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      await user.updateDisplayName(name);

      // Create user in Firestore with all required fields
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'phone': phone,
        'email': email.trim().toLowerCase(),
        'role': role.toLowerCase(),
        'isVerified': false, // Always include this field
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save auth state
      await _saveAuthState(user.uid, role.toLowerCase());
      return user;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in with email and password (New style - returns UserModel)
  static Future<UserModel> signInWithModel({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to sign in');
      }

      final userModel = await FirestoreService.getUserProfile(userCredential.user!.uid);
      
      if (userModel == null) {
        throw Exception('User profile not found');
      }

      await _storeLoginState(userModel);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign in (Old style - for backward compatibility)
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      final role = await getCurrentUserRole();
      if (role != null && _auth.currentUser != null) {
        await _saveAuthState(_auth.currentUser!.uid, role);
      }
      
      return role;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign out (Works for both styles)
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _clearLoginState();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Sign out (Instance method for backward compatibility)
  Future<void> signOutInstance() async {
    await signOut();
  }

  /// Get current user role from Firestore (Old style compatibility)
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    
    final data = doc.data();
    return data?['role'] as String?;
  }

  /// Get current user profile (New style)
  static Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) {
        print('DEBUG: AuthService - No current Firebase user');
        return null;
      }
      print('DEBUG: AuthService - Current Firebase user ID: ${user.uid}');
      print('DEBUG: AuthService - Current Firebase user email: ${user.email}');
      final userProfile = await FirestoreService.getUserProfile(user.uid);
      if (userProfile != null) {
        print('DEBUG: AuthService - Retrieved user profile: ${userProfile.name} (${userProfile.role.name})');
      } else {
        print('DEBUG: AuthService - No user profile found for ID: ${user.uid}');
      }
      return userProfile;
    } catch (e) {
      print('DEBUG: AuthService - Error getting current user profile: $e');
      return null;
    }
  }

  /// Check if current user is verified (for Qaris)
  static Future<bool> isCurrentUserVerified() async {
    try {
      final userProfile = await getCurrentUserProfile();
      return userProfile?.isVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check if current user has specific role
  static Future<bool> hasRole(UserRole role) async {
    try {
      final userProfile = await getCurrentUserProfile();
      return userProfile?.role == role;
    } catch (e) {
      return false;
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Update user password
  static Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  /// Update user email
  static Future<void> updateEmail(String newEmail) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      
      await user.verifyBeforeUpdateEmail(newEmail);
      await FirestoreService.updateUserProfile(user.uid, {'email': newEmail});
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  /// Re-authenticate user
  static Future<void> reauthenticate(String password) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user is currently signed in');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Re-authentication failed: $e');
    }
  }

  /// Delete user account
  static Future<void> deleteAccount(String password) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      await reauthenticate(password);
      await FirestoreService.deleteUserAccount(user.uid);
      await user.delete();
      await _clearLoginState();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Store login state in SharedPreferences
  static Future<void> _storeLoginState(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userRoleKey, user.role.name);
    await prefs.setString(_userIdKey, user.id);
  }

  /// Save auth state (Old style compatibility)
  Future<void> _saveAuthState(String userId, String userRole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userRoleKey, userRole.toLowerCase());
    await prefs.setString(_userIdKey, userId);
  }

  /// Public method for saving auth state (Old style compatibility)
  Future<void> saveAuthState(String userId, String userRole) async {
    await _saveAuthState(userId, userRole);
  }

  /// Clear login state from SharedPreferences
  static Future<void> _clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userIdKey);
  }

  /// Static method to clear auth state (Old style compatibility)
  static Future<void> clearAuthState() async {
    await _clearLoginState();
  }

  /// Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  /// Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 6 && 
           RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(password);
  }

  /// Get password strength text
  static String getPasswordStrengthText(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Too short';
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(password)) {
      return 'Must contain letters and numbers';
    }
    if (password.length < 8) return 'Good';
    if (RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#$%^&*])').hasMatch(password)) {
      return 'Strong';
    }
    return 'Good';
  }
}
