import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qari_connect/controllers/services/authentication/auth_services.dart';

class QariDashboard extends StatelessWidget {
  const QariDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qari Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.instance.signOut();
              if (context.mounted) {
                context.go('/sign-in');
              }
            },
          ),
        ],
      ),
      body: const Center(child: Text('Welcome, Qari!')),
    );
  }
}
