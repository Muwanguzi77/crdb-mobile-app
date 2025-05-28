import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/home/deposit_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Centenary Bank',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  String _accessToken = '';
  bool _isAuthenticated = false;

  // final String _clientId = 'y82yFckTUMGfINb5IN7PVm9zXSUa';
  // final String _redirectUrl = 'wso2login://oauth2redirect';
  // final String _issuer = 'https://10.173.78.232:9443/oauth2/token';
  // final String _authorizationEndpoint = 'https://10.173.78.232:9443/oauth2/authorize';
  // final String _tokenEndpoint = 'https://10.173.78.232:9443/oauth2/token';
  //Below is the ip of my machine when connected to my iPhone
  final String _clientId = 'y82yFckTUMGfINb5IN7PVm9zXSUa';
  final String _redirectUrl = 'wso2login://oauth2redirect';
  final String _issuer = 'https://172.20.10.2:9443/oauth2/token';
  final String _authorizationEndpoint = 'https://172.20.10.2:9443/oauth2/authorize';
  final String _tokenEndpoint = 'https://172.20.10.2:9443/oauth2/token';
  Future<void> _authenticate() async {
    try {
      final AuthorizationTokenResponse? result =
      await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: _authorizationEndpoint,
            tokenEndpoint: _tokenEndpoint,
          ),
          scopes: ['openid', 'profile', 'email'],
        ),
      );

      print("Printing result From WSO2");
      print(result);
      if (result != null) {
        print("Logged In Successfully");
        setState(() {
          _accessToken = result.accessToken!;
          _isAuthenticated = true;
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false, // removes all previous routes
        );
      }
    } catch (e) {
      print('Login Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centenary Bank'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/mapeera.jpg',
            fit: BoxFit.cover,
          ),

          // Foreground Content
          Center(
            child: _isAuthenticated
                ? Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white.withOpacity(0.8),
              child: Text(
                'Login Successful, Token: $_accessToken',
                style: const TextStyle(fontSize: 16),
              ),
            )
                : Container(
              padding: const EdgeInsets.all(24.0),
              margin: const EdgeInsets.symmetric(horizontal: 32.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: const Text('LOGIN '),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RegisterScreen()),
                      );
                    },
                    child: const Text("Don't have an account? Register"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    },
                    child: const Text("Home"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
