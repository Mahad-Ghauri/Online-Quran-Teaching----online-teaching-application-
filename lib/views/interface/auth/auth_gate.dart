import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qari_connect/views/screens/splashscreen.dart';
import 'package:qari_connect/views/interface/auth/auth_selection_screen.dart';
import 'package:qari_connect/controllers/services/authentication/auth_services.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;

  // Debounce navigation and manage auth stream
  StreamSubscription<User?>? _authSub;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeAuthGate().whenComplete(_listenToAuthChanges);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _initializeAuthGate() async {
    try {
      // First check locally stored auth state
      final prefs = await SharedPreferences.getInstance();
      final isLocallyLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final localUserRoleRaw = prefs.getString('user_role');
      final localUserId = prefs.getString('user_id');

      final localUserRole = localUserRoleRaw?.toLowerCase();
      debugPrint('🔐 Auth Gate - Local State: isLoggedIn=$isLocallyLoggedIn, role=${localUserRoleRaw}');

      if (isLocallyLoggedIn && localUserRole != null && localUserId != null) {
        // Normalize any legacy role casing stored locally
        if (localUserRoleRaw != null && localUserRoleRaw != localUserRole) {
          await AuthService.instance.saveAuthState(localUserId, localUserRole);
        }

        // User was previously logged in, verify with Firebase
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null && currentUser.uid == localUserId) {
          // Firebase session is still valid
          debugPrint('✅ Auth Gate - Firebase session valid, navigating to dashboard');
          await _navigateToUserDashboard(localUserRole);
          if (mounted) setState(() => _isLoading = false);
          return;
        } else {
          // Firebase session expired, but local state says logged in
          debugPrint('⚠️ Auth Gate - Firebase session expired, clearing local state');
          await _clearAuthState();
        }
      }

      // No valid local session, check Firebase auth state
      await _checkFirebaseAuthState();
    } catch (e) {
      debugPrint('❌ Auth Gate - Initialization error: $e');
      await _clearAuthState();
      _showAuthSelection();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _listenToAuthChanges() {
    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (!mounted) return;
      if (user == null) {
        debugPrint('🚪 Auth Gate - User signed out, clearing state and navigating to /auth');
        await _clearAuthState();
        _showAuthSelection();
      } else {
        debugPrint('🔐 Auth Gate - User signed in during session');
        // Re-check role and navigate accordingly
        await _checkFirebaseAuthState();
      }
    });
  }

  Future<void> _checkFirebaseAuthState() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      debugPrint('🔥 Auth Gate - Firebase user exists: ${user.uid}');
      try {
        // Get user role from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final userRole = userData['role'] as String?;

          if (userRole != null) {
            debugPrint('✅ Auth Gate - User role found: $userRole');
            // Save auth state locally for persistent login
            await AuthService.instance.saveAuthState(user.uid, userRole);
            await _navigateToUserDashboard(userRole);
            return;
          }
        }

        // User exists but no valid role, sign out
        debugPrint('⚠️ Auth Gate - No valid user role, signing out');
        await AuthService.instance.signOut();
        await _clearAuthState();
      } catch (e) {
        debugPrint('❌ Auth Gate - Error fetching user data: $e');
        await AuthService.instance.signOut();
        await _clearAuthState();
      }
    }

    // No Firebase user or invalid state
    _showAuthSelection();
  }

  Future<void> _clearAuthState() async {
    await AuthService.clearAuthState();
  }

  Future<void> _navigateToUserDashboard(String userRole) async {
    if (!mounted) return;
    final role = userRole.toLowerCase();
    switch (role) {
      case 'qari':
        _safeGo('/qari-dashboard');
        break;
      case 'student':
        _safeGo('/student-dashboard');
        break;
      default:
        debugPrint('⚠️ Auth Gate - Unknown role: $userRole');
        await _clearAuthState();
        _showAuthSelection();
    }
  }

  void _showAuthSelection() {
    if (!mounted) return;
    _safeGo('/auth');
  }

  // Prevent rapid repeated navigations that can cause flicker
  void _safeGo(String route) {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;
    context.go(route);
    // Reset navigating flag shortly after to allow future navigations
    Future.delayed(const Duration(milliseconds: 300), () {
      _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Keep UI minimal; routing is handled via navigation above
    return const SplashScreen();
  }
}