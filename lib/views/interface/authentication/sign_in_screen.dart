// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qari_connect/components/my_form_field.dart';
import 'package:qari_connect/components/primary_button.dart';
import 'package:qari_connect/config/theme.dart';
import 'package:qari_connect/controllers/input_controller.dart';
import 'package:qari_connect/controllers/services/authentication/auth_services.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final InputControllers inputs = InputControllers();

  @override
  void dispose() {
    inputs.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final form = inputs.formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    setState(() => inputs.loading = true);
    try {
      final role = await AuthService.instance.signIn(
        email: inputs.emailController.text,
        password: inputs.passwordController.text,
      );

      if (!mounted) return;

      if (role == 'Qari') {
        context.go('/dashboard/qari');
      } else {
        context.go('/dashboard/student');
      }
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => inputs.loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign In')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: inputs.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  MyFormField(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: inputs.emailController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Email is required' : null,
                  ),
                  const SizedBox(height: 16),
                  MyFormField(
                    labelText: 'Password',
                    hintText: 'Your password',
                    controller: inputs.passwordController,
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Sign In',
                    loading: inputs.loading,
                    onPressed: _handleSignIn,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/sign-up'),
                    child: const Text("Don't have an account? Sign Up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
