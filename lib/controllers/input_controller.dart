import 'package:flutter/widgets.dart';


class InputControllers {
  //  Loading variable
  bool loading = false;
  //  Form Validator
  final formKey = GlobalKey<FormState>();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();


  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    
  }
}