import 'package:findu/ui/components/drawer_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final supabaseUrl ='https://xnwxjxayemwgomenhvbi.supabase.co';
  final anonKey ='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhud3hqeGF5ZW13Z29tZW5odmJpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxOTUzODIsImV4cCI6MjA1OTc3MTM4Mn0.QwRMmDqP0A06dbdkSmN4xIZ8oy5V6pOBlSmiCjh20qc';
  await Supabase.initialize(url: supabaseUrl!, anonKey: anonKey!);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FindU App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF009688),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF009688),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF009688),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFF009688),
              width: 2,
            ),
          ),
        ),
      ),
      home: const Scaffold(
        body: Center(child: DrawerLogin()),
      ),
    );
  }
}
