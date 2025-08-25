// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qari_connect/components/my_form_field.dart';
import 'package:qari_connect/components/primary_button.dart';
import 'package:qari_connect/config/theme.dart';
import 'package:qari_connect/controllers/input_controller.dart';
import 'package:qari_connect/controllers/services/authentication/auth_services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final InputControllers inputs = InputControllers();
  String _role = 'Student';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
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
      if (_role == 'Qari') {
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
        appBar: AppBar(title: const Text('Sign Up')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: inputs.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  MyFormField(
                    labelText: 'Full Name',
                    hintText: 'John Doe',
                    controller: inputs.nameController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  MyFormField(
                    labelText: 'Phone',
                    hintText: '+1 555 123 4567',
                    keyboardType: TextInputType.phone,
                    controller: inputs.phoneController,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Phone is required' : null,
                  ),
                  const SizedBox(height: 16),
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
                    hintText: 'Create a password',
                    controller: inputs.passwordController,
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  MyFormField(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    controller: inputs.confirmPasswordController,
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _role,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Student',
                        child: Text('Student'),
                      ),
                      DropdownMenuItem(value: 'Qari', child: Text('Qari')),
                    ],
                    onChanged: (v) => setState(() => _role = v ?? 'Student'),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Create Account',
                    loading: inputs.loading,
                    onPressed: _handleSignUp,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/sign-in'),
                    child: const Text('Already have an account? Sign In'),
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
