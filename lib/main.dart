import 'package:findu/ui/components/drawer_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final supabaseUrl = dotenv.env['URL_SUPABASE'];
  final anonKey = dotenv.env['ANON_KEY'];

  await Supabase.initialize(url: supabaseUrl!, anonKey: anonKey!);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: DrawerLogin())),
    );
  }
}
