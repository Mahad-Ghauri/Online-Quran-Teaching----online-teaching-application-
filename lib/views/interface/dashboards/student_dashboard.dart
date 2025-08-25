import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qari_connect/services/auth_service.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                context.go('/sign-in');
              }
            },
          ),
        ],
      ),
      body: const Center(child: Text('Welcome, Student!')),
    );
  }
}
