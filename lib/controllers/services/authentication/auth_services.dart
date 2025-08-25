import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication and user-role management service
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Keys for SharedPreferences
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserId = 'user_id';

  User? get currentUser => _auth.currentUser;

  /// Sign up user and save profile with role in Firestore
  Future<User?> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role, // "Student" or "Qari"
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) return null;

    await user.updateDisplayName(name);

    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'phone': phone,
      'email': email.trim().toLowerCase(),
      'role': role.toLowerCase(), // normalized to lowercase
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Save auth state locally after successful signup
    await _saveAuthState(user.uid, role.toLowerCase());

    return user;
  }

  /// Sign in and return the user's role (if found)
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    
    final role = await getCurrentUserRole();
    if (role != null && _auth.currentUser != null) {
      // Save auth state locally after successful signin
      await _saveAuthState(_auth.currentUser!.uid, role);
    }
    
    return role;
  }

  Future<void> signOut() async {
    try {
      // Clear local auth state first
      await _clearAuthState();
      
      // Then sign out from Firebase
      await _auth.signOut();
      
      print('✅ Auth Service - Successfully signed out and cleared local state');
    } catch (e) {
      print('❌ Auth Service - Error during sign out: $e');
      // Still attempt to sign out from Firebase even if local clear fails
      await _auth.signOut();
    }
  }

  /// Save authentication state locally (public method)
  Future<void> saveAuthState(String userId, String userRole) async {
    await _saveAuthState(userId, userRole);
  }

  /// Save authentication state locally
  Future<void> _saveAuthState(String userId, String userRole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, userRole.toLowerCase());
    await prefs.setString(_keyUserId, userId);
    print('💾 Auth Service - Saved auth state: userId=$userId, role=$userRole');
  }

  /// Clear local authentication state
  Future<void> _clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyUserId);
    print('🗑️ Auth Service - Cleared local auth state');
  }

  /// Static method to clear auth state (can be called from anywhere)
  static Future<void> clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyUserId);
    print('🗑️ Auth Service - Static clear auth state called');
  }

  /// Fetch current user's role from Firestore
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    final role = data?['role'] as String?;
    return role?.toLowerCase();
  }

  /// Stream to observe auth state
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
