import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../main.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      setState(() => _loading = true);
      final url = Uri.parse("http://172.20.10.2:8080/createCustomer");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "first_name": _firstNameController.text,
          "last_name": _lastNameController.text,
          "email": _emailController.text,
          "phone_number": _phoneController.text,
          "address": _addressController.text,
        }),
      );

      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MyApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Replace with your image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // Form Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 20),
                        CustomInput(controller: _firstNameController, hint: 'First Name', icon: Icons.person),
                        SizedBox(height: 12),
                        CustomInput(controller: _lastNameController, hint: 'Last Name', icon: Icons.person_outline),
                        SizedBox(height: 12),
                        CustomInput(controller: _emailController, hint: 'Email', icon: Icons.email),
                        SizedBox(height: 12),
                        CustomInput(controller: _phoneController, hint: 'Phone Number', icon: Icons.phone),
                        SizedBox(height: 12),
                        CustomInput(controller: _addressController, hint: 'Address', icon: Icons.home),
                        SizedBox(height: 12),
                        CustomInput(controller: _passwordController, hint: 'Password', icon: Icons.lock, obscure: true),
                        SizedBox(height: 12),
                        CustomInput(controller: _confirmPasswordController, hint: 'Confirm Password', icon: Icons.lock_outline, obscure: true),
                        SizedBox(height: 20),
                        _loading
                            ? CircularProgressIndicator()
                            : CustomButton(text: 'Register', onPressed: _register),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => LoginScreen()),
                            );
                          },
                          child: Text(
                            "Already have an account? Login",
                            style: TextStyle(color: Colors.blue[800]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
