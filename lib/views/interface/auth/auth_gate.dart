import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qari_connect/views/screens/splashscreen.dart';
import 'package:qari_connect/providers/app_providers.dart';
import 'package:qari_connect/models/core_models.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  StreamSubscription<User?>? _authSub;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _initializeAuthGate();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _initializeAuthGate() async {
    try {
      final authProvider = context.read<AuthProvider>();
      
      // Initialize auth state from stored session
      await authProvider.initializeAuth();
      
      // Listen to Firebase auth changes
      _listenToAuthChanges();
      
      // Navigate based on current auth state
      if (authProvider.isAuthenticated) {
        await _navigateToUserDashboard(authProvider.currentUser!.role);
      } else {
        _showAuthSelection();
      }
    } catch (e) {
      debugPrint('❌ Auth Gate - Initialization error: $e');
      _showAuthSelection();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _listenToAuthChanges() {
    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (!mounted) return;
      
      final authProvider = context.read<AuthProvider>();
      
      if (user == null) {
        debugPrint('� Auth Gate - User signed out');
        await authProvider.signOut();
        _showAuthSelection();
      } else {
        debugPrint('� Auth Gate - User signed in: ${user.uid}');
        // Auth provider will handle the user profile loading
        if (authProvider.isAuthenticated) {
          await _navigateToUserDashboard(authProvider.currentUser!.role);
        }
      }
    });
  }

  Future<void> _navigateToUserDashboard(UserRole userRole) async {
    if (!mounted) return;
    
    switch (userRole) {
      case UserRole.qari:
        _safeGo('/qari-dashboard');
        break;
      case UserRole.student:
        _safeGo('/student-dashboard');
        break;
      case UserRole.admin:
        // For now, redirect admin to qari dashboard
        // TODO: Create admin dashboard
        _safeGo('/qari-dashboard');
        break;
    }
  }

  void _showAuthSelection() {
    if (!mounted) return;
    _safeGo('/auth');
  }

  // Prevent rapid repeated navigations
  void _safeGo(String route) {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;
    context.go(route);
    // Reset navigating flag after delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (_isLoading || authProvider.isLoading) {
          return const SplashScreen();
        }
        
        // This should not be reached as navigation happens in initState
        // But just in case, show splash screen
        return const SplashScreen();
      },
    );
  }
}