import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/admin_user.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String supabaseUrl = 'https://xnwxjxayemwgomenhvbi.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhud3hqeGF5ZW13Z29tZW5odmJpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQxOTUzODIsImV4cCI6MjA1OTc3MTM4Mn0.QwRMmDqP0A06dbdkSmN4xIZ8oy5V6pOBlSmiCjh20qc';

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Autenticação
  Future<AdminUser?> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Por enquanto, vamos criar um usuário admin mock
        // Em produção, isso viria do banco de dados
        return AdminUser(
          id: response.user!.id,
          email: response.user!.email ?? email,
          name: 'Administrador',
          role: 'admin',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isActive: true,
        );
      }
      return null;
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<AdminUser?> getCurrentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    try {
      // Por enquanto, retornamos um usuário mock
      // Em produção, isso viria do banco de dados
      return AdminUser(
        id: user.id,
        email: user.email ?? 'admin@findu.com',
        name: 'Administrador',
        role: 'admin',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isActive: true,
      );
    } catch (e) {
      print('Erro ao buscar usuário atual: $e');
      return null;
    }
  }

  bool get isAuthenticated => client.auth.currentUser != null;

  // Stream para mudanças de autenticação
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
