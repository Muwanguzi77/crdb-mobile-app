import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'dart:async';
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
      // home: _initialScreen(),
    );
  }

  Widget _initialScreen() {
    //This
    // if (_LoginScreenState.cachedAccessToken != null) {
    //   return HomeScreen();
    // }
    return LoginScreen();
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static String? cachedAccessToken;
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  String _accessToken = '';
  bool _isAuthenticated = false;
  StreamSubscription? _sub;

  final String _clientId = 'y82yFckTUMGfINb5IN7PVm9zXSUa';
  final String _redirectUrl = 'centenary://oauth2redirect/home';
  final String _issuer = 'https://10.173.78.232:9443/oauth2/token';
  final String _authorizationEndpoint = 'https://10.173.78.232:9443/oauth2/authorize';
  final String _tokenEndpoint = 'https://10.173.78.232:9443/oauth2/token';

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() { //to handle redirect to a specific screen
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        final screen = uri.queryParameters['screen'] ?? (uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null);
        print("Redirected to: \${uri.toString()} | Target screen: \$screen");

        if (screen == 'home') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
        // else if (screen == 'deposit') {
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => DepositScreen()),
        //   );
        // }
      }
    }, onError: (err) {
      print('Failed to handle link: \$err');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

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
          promptValues: ['login'], // 👈 Force reauthentication prompt
        ),
      ).timeout(Duration(seconds: 200), onTimeout: () {
        print("❌****** Timed out waiting for redirect!******");
        return null;
      });

      print(result);
      if (result != null) {
        setState(() {
          _accessToken = result.accessToken!;
          cachedAccessToken = _accessToken;
          _isAuthenticated = true;
        });
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
          Image.asset(
            'assets/mapeera.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: _isAuthenticated
                ? Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white.withOpacity(0.8),
              child: Text(
                'Login Successful, Token: \$_accessToken',
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
                  // TextButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (_) => HomeScreen()),
                  //     );
                  //   },
                  //   child: const Text("Home"),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}