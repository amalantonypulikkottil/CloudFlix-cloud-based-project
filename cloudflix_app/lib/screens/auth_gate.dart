import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? isLoggedIn;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      String? token = await AuthService.getToken();

      if (token != null && token.isNotEmpty) {
        bool isExpired = JwtDecoder.isExpired(token);
        if (!isExpired) {
          setState(() => isLoggedIn = true);
        } else {
          // Token expired, clear it
          await AuthService.logout();
          setState(() => isLoggedIn = false);
        }
      } else {
        setState(() => isLoggedIn = false);
      }
    } catch (e) {
      debugPrint("Auth check error: $e");
      setState(() => isLoggedIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.movie_creation, size: 80, color: Colors.red[700]),
              const SizedBox(height: 20),
              Text(
                'CloudFlix',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    return isLoggedIn! ? const HomeScreen() : const LoginScreen();
  }
}
