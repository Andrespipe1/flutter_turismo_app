import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onLoginTap;
  const RegisterPage({super.key, required this.onLoginTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  String role = 'visitante';
  bool loading = false;
  String? error;

  Future<void> register() async {
    setState(() { loading = true; error = null; });
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: passController.text,
      );
      if (res.user != null) {
        // Guarda el rol en la tabla roles
        await Supabase.instance.client.from('roles').insert({
          'user_id': res.user!.id,
          'role': role,
        });
        setState(() {
          error = null;
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registro exitoso'),
            content: const Text('Revisa tu email para confirmar tu cuenta antes de iniciar sesión.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onLoginTap();
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    } on AuthException catch (e) {
      if (e.message.contains('invalid email')) {
        setState(() { error = 'Correo inválido.'; });
      } else if (e.message.contains('already registered')) {
        setState(() { error = 'La cuenta ya está registrada.'; });
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
                    const Icon(Icons.person_add_alt_1, size: 64, color: Color(0xFF6D5BFF)),
                    const SizedBox(height: 16),
                    Text("Registro", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(
                        labelText: "Rol",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.verified_user),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'visitante', child: Text('Visitante')),
                        DropdownMenuItem(value: 'publicador', child: Text('Publicador')),
                      ],
                      onChanged: (v) => setState(() => role = v!),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D5BFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Registrarse", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onLoginTap,
                      child: const Text("¿Ya tienes cuenta? Inicia sesión", style: TextStyle(color: Color(0xFF6D5BFF))),
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