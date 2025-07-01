import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onRegisterTap;
  const LoginPage({super.key, required this.onRegisterTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> login() async {
    setState(() { loading = true; error = null; });
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text,
        password: passController.text,
      );
      if (res.user == null) {
        setState(() { error = "Correo o contraseña incorrectos"; });
      } else if (res.user != null && !(res.user!.emailConfirmedAt != null)) {
        setState(() { error = "Debes confirmar tu correo antes de iniciar sesión."; });
      }
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        setState(() { error = 'Correo o contraseña incorrectos.'; });
      } else if (e.message.contains('Email not confirmed')) {
        setState(() { error = 'Debes confirmar tu correo antes de iniciar sesión.'; });
      } else {
        setState(() { error = e.message; });
      }
    } catch (e) {
      setState(() { error = 'Error inesperado: $e'; });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6D5BFF), Color(0xFFB9AFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 64, color: Color(0xFF6D5BFF)),
                    const SizedBox(height: 16),
                    Text("Iniciar Sesión", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Correo",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passController,
                      decoration: const InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D5BFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Entrar", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onRegisterTap,
                      child: const Text("¿No tienes cuenta? Regístrate", style: TextStyle(color: Color(0xFF6D5BFF))),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 