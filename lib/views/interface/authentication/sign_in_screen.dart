// Enhanced Sign In Screen
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qari_connect/components/auth_form.dart';
import 'package:qari_connect/components/auth_header.dart';
import 'package:qari_connect/components/glassmorphism_button.dart';
import 'package:qari_connect/components/gradient_background.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => inputs.loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const AuthHeader(
                title: 'Welcome Back',
                subtitle: 'Sign in to continue your journey',
                logoPath: 'assets/icons/logo.png',
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: AuthForm(
                      formKey: inputs.formKey,
                      children: [
                        AuthFormField(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          controller: inputs.emailController,
                          prefixIcon: Icons.email_outlined,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Email is required'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        AuthFormField(
                          labelText: 'Password',
                          hintText: 'Your password',
                          controller: inputs.passwordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Min 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 32),
                        GlassmorphismButton(
                          label: 'Sign In',
                          loading: inputs.loading,
                          onPressed: _handleSignIn,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => context.go('/sign-up'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: RichText(
                              text: const TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: Colors.white70),
                                children: [
                                  TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}