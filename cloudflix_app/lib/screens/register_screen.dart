import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void register() async {
    setState(() => isLoading = true);

    bool success = await AuthController.register(
      nameController.text,
      emailController.text,
      passwordController.text,
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration successful. Please login")),
      );

      Navigator.pop(context); // Go back to login
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Registration failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Create Account", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: isLoading ? null : register,
              child: isLoading ? CircularProgressIndicator() : Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
