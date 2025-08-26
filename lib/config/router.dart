import 'package:go_router/go_router.dart';
import 'package:qari_connect/views/screens/splashscreen.dart';
import 'package:qari_connect/services/auth_gate.dart';
import 'package:qari_connect/views/interface/authentication/auth_selection_screen.dart';
import 'package:qari_connect/views/interface/authentication/sign_in_screen.dart';
import 'package:qari_connect/views/interface/authentication/sign_up_screen.dart';
import 'package:qari_connect/views/interface/dashboards/qari/qari_main_dashboard.dart';
import 'package:qari_connect/views/interface/dashboards/student/student_main_dashboard.dart';
import 'package:qari_connect/views/interface/dashboards/admin/admin_main_dashboard.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    // Auth Gate - Main entry point
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
    ),
    
    // Splash Screen
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    
    // Auth Selection Screen
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthSelectionScreen(),
    ),
    
    // Authentication Screens
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => SignUpScreen(
        initialRole: (state.extra is Map) ? (state.extra as Map)['role'] as String? : null,
      ),
    ),
    
    // Dashboard Routes
    GoRoute(
      path: '/qari-dashboard',
      builder: (context, state) => const QariMainDashboard(),
    ),
    GoRoute(
      path: '/student-dashboard',
      builder: (context, state) => const StudentMainDashboard(),
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminMainDashboard(),
    ),
    
    // Legacy routes for backward compatibility
    GoRoute(
      path: '/dashboard/qari',
      redirect: (context, state) => '/qari-dashboard',
    ),
    GoRoute(
      path: '/dashboard/student',
      redirect: (context, state) => '/student-dashboard',
    ),
  ],
);
