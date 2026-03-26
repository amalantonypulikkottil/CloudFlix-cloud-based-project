import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(CloudFlixApp());
}

class CloudFlixApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CloudFlix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: LoginScreen(),
    );
  }
}
