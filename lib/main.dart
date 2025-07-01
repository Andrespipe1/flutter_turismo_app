import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://uzfjlndypjonnkugeaev.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV6ZmpsbmR5cGpvbm5rdWdlYWV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgyOTcxODAsImV4cCI6MjA2Mzg3MzE4MH0.UlYtqJEKF8C23bDFcNPXGXutBjVryalnm07onBRxxAY',
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool showLogin = true;

  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {}); // Reconstruye cuando cambia la sesión
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: session != null
          ? const HomePage()
          : showLogin
              ? LoginPage(onRegisterTap: () => setState(() => showLogin = false))
              : RegisterPage(onLoginTap: () => setState(() => showLogin = true)),
    );
  }
}
