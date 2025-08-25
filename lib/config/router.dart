import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qari_connect/screens/splashscreen.dart';
import 'package:qari_connect/views/interface/authentication/sign_in_screen.dart';
import 'package:qari_connect/views/interface/authentication/sign_up_screen.dart' hide SignInScreen;
import 'package:qari_connect/views/interface/dashboards/qari_dashboard.dart';
import 'package:qari_connect/views/interface/dashboards/student_dashboard.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/dashboard/student',
      builder: (context, state) => const StudentDashboard(),
    ),
    GoRoute(
      path: '/dashboard/qari',
      builder: (context, state) => const QariDashboard(),
    ),
  ],
);
