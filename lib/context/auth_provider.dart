// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _service = SupabaseService();
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _init();
  }

  void _init() {
    _user = Supabase.instance.client.auth.currentUser;

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      _user = session?.user;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    final res = await _service.login(email, password);
    _user = res.user;
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    final res = await _service.signUp(email, password);
    _user = res.user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    notifyListeners();
  }
}
