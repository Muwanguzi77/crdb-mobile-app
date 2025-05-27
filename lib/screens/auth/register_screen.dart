// import 'package:crdb_mobile_app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../main.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';
// import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
      final url = Uri.parse("http://10.0.2.2:8080/createCustomer");
      final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "first_name": _firstNameController.text,
            "last_name": _lastNameController.text,
            "email": _emailController.text,
            "phone_number": _phoneController.text,
            "address": _addressController.text,
            // "password": _passwordController.text
          })
      );

      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MyApp()),
      );

      // if (response.statusCode == 200) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Registration successful')),
      //   );
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (_) => LoginScreen()),
      //   );
      // } else {
      //   final Map<String, dynamic> data = jsonDecode(response.body);
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text(data['message'] ?? 'Registration failed')),
      //   );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Register", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  CustomInput(controller: _firstNameController, hint: 'First Name', icon: Icons.person),
                  SizedBox(height: 10),
                  CustomInput(controller: _lastNameController, hint: 'Last Name', icon: Icons.person_outline),
                  SizedBox(height: 10),
                  CustomInput(controller: _emailController, hint: 'Email', icon: Icons.email),
                  SizedBox(height: 10),
                  CustomInput(controller: _phoneController, hint: 'Phone Number', icon: Icons.phone),
                  SizedBox(height: 10),
                  CustomInput(controller: _addressController, hint: 'Address', icon: Icons.credit_card),
                  SizedBox(height: 10),
                  CustomInput(controller: _passwordController, hint: 'Password', icon: Icons.lock, obscure: true),
                  SizedBox(height: 10),
                  CustomInput(controller: _confirmPasswordController, hint: 'Confirm Password', icon: Icons.lock_outline, obscure: true),
                  SizedBox(height: 20),
                  _loading
                      ? CircularProgressIndicator()
                      : CustomButton(text: 'Register', onPressed: _register),
                  SizedBox(height: 10),
                  // TextButton(
                  //   child: Text("Already have an account? Login"),
                  //   onPressed: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (_) => HomeScreen()),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// TODO Implement this library.