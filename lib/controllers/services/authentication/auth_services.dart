import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Authentication and user-role management service
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
      'role': role, // Student or Qari
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

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
    return getCurrentUserRole();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Fetch current user's role from Firestore
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    return data?['role'] as String?;
  }

  /// Stream to observe auth state
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
