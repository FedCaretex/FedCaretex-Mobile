import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../../models/prediction_models.dart';

class AuthNotifier extends StateNotifier<AuthSession?> {
  AuthNotifier() : super(null) {
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('user_id');
    final name = prefs.getString('name');
    final email = prefs.getString('email');
    final photoUrl = prefs.getString('photo_url');
    if (token != null && userId != null && name != null && email != null) {
      state = AuthSession(
        token: token,
        userId: userId,
        name: name,
        email: email,
        photoUrl: photoUrl,
      );
    }
  }

  Future<void> login(String email, String password) async {
    final json = await apiClient.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    await _persist(AuthSession.fromJson(json as Map<String, dynamic>));
  }

  Future<void> enterGuest() async {
    await _persist(
      const AuthSession(
        token: 'local-demo',
        userId: 'demo-user',
        name: 'Rownok',
        email: 'demo@fedcaretex.ai',
      ),
    );
  }

  Future<void> register(String name, String email, String password) async {
    final json = await apiClient.post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
    });
    await _persist(AuthSession.fromJson(json as Map<String, dynamic>));
  }

  Future<void> _persist(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', session.token);
    await prefs.setString('user_id', session.userId);
    await prefs.setString('name', session.name);
    await prefs.setString('email', session.email);
    if (session.photoUrl != null && session.photoUrl!.isNotEmpty) {
      await prefs.setString('photo_url', session.photoUrl!);
    } else {
      await prefs.remove('photo_url');
    }
    state = session;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthSession?>((ref) {
  return AuthNotifier();
});
