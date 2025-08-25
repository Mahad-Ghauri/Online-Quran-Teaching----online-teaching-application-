// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qari_connect/components/auth_form.dart';
import 'package:qari_connect/components/auth_header.dart';
import 'package:qari_connect/components/gradient_background.dart';
import 'package:qari_connect/components/glassmorphism_button.dart';
import 'package:qari_connect/controllers/input_controller.dart';
import 'package:qari_connect/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  final String? initialRole; // expects 'qari' or 'student' (any case)
  const SignUpScreen({super.key, this.initialRole});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final InputControllers inputs = InputControllers();
  String _role = 'student';

  @override
  void initState() {
    super.initState();
    // Initialize role from navigation extra if provided
    final incoming = widget.initialRole?.toLowerCase();
    if (incoming == 'qari') {
      _role = 'qari';
    } else if (incoming == 'student') {
      _role = 'student';
    }
  }

  @override
  void dispose() {
    inputs.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final form = inputs.formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    if (inputs.passwordController.text !=
        inputs.confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => inputs.loading = true);
    try {
      await AuthService.instance.signUp(
        name: inputs.nameController.text,
        phone: inputs.phoneController.text,
        email: inputs.emailController.text,
        password: inputs.passwordController.text,
        role: _role,
      );

      if (!mounted) return;
      if (_role.toLowerCase() == 'qari') {
        context.go('/qari-dashboard');
      } else {
        context.go('/student-dashboard');
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
        colors: [
          const Color(0xFF2196F3),
          const Color(0xFF21CBF3),
          const Color(0xFF4CAF50),
          const Color(0xFF2196F3),
        ],
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const AuthHeader(
                title: 'Create Account',
                subtitle: 'Join us on your learning journey',
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
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          controller: inputs.nameController,
                          prefixIcon: Icons.person_outline,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Name is required'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        AuthFormField(
                          labelText: 'Phone',
                          hintText: '+92xxxxxxxxxx',
                          keyboardType: TextInputType.phone,
                          controller: inputs.phoneController,
                          prefixIcon: Icons.phone_outlined,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Phone is required'
                              : null,
                        ),
                        const SizedBox(height: 20),
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
                          hintText: 'Create a password',
                          controller: inputs.passwordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Min 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        AuthFormField(
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          controller: inputs.confirmPasswordController,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Min 6 characters'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        // Glassmorphism Role Selector
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Role',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _role.toLowerCase(),
                                dropdownColor: const Color(0xFF2196F3).withOpacity(0.9),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.school_outlined,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'student',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.school,
                                          color: Colors.white.withOpacity(0.8),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Student',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'qari',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.person_4,
                                          color: Colors.white.withOpacity(0.8),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Qari',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _role = (v ?? 'student').toLowerCase()),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        GlassmorphismButton(
                          label: 'Create Account',
                          loading: inputs.loading,
                          onPressed: _handleSignUp,
                          icon: Icons.person_add,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => context.go('/sign-in'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: RichText(
                              text: const TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(color: Colors.white70),
                                children: [
                                  TextSpan(
                                    text: "Sign In",
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