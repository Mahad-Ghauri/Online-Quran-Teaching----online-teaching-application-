// controllers/input_controller.dart - Updated version with additional controllers
import 'package:flutter/material.dart';

class InputControllers {
  // Form key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  
  // Loading state
  bool loading = false;
  
  // Role selection for sign up (if needed)
  String? selectedRole;
  
  // Dispose all controllers
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
  }
  
  // Clear all fields
  void clear() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    confirmPasswordController.clear();
    phoneController.clear();
    selectedRole = null;
  }
  
  // Validate form
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }
} 