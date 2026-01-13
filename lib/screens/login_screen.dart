import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRegister = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isRegister ? "Buat Akun" : "Selamat Datang", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (isRegister) {
                  await signUp(emailController.text, passwordController.text);
                } else {
                  await signIn(emailController.text, passwordController.text);
                }
              },
              child: Text(isRegister ? "Daftar" : "Masuk"),
            ),
            TextButton(
              onPressed: () => setState(() => isRegister = !isRegister),
              child: Text(isRegister ? "Sudah punya akun? Login" : "Belum punya akun? Daftar"),
            ),
          ],
        ),
      ),
    );
  }
}