import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Exemplo: login com e-mail e senha
  Future<AuthResponse> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Exemplo: cadastro
  Future<AuthResponse> signUp(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  // Exemplo futuro: buscar dados de uma tabela
  // Future<List<Map<String, dynamic>>> getDados(String table) async {
  //   final response = await _client.from(table).select().execute();

  //   if (response.error != null) {
  //     throw response.error!;
  //   }

  //   return List<Map<String, dynamic>>.from(response.data);
  // }

  // Exemplo: logout
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
