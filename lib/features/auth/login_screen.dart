import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/fade_in.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController(text: 'demo@fedcaretex.ai');
  final _password = TextEditingController(text: 'demo123');
  final _name = TextEditingController();
  bool _register = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_register) {
        await ref.read(authProvider.notifier).register(
              _name.text.trim(),
              _email.text.trim(),
              _password.text,
            );
      } else {
        await ref.read(authProvider.notifier).login(
              _email.text.trim(),
              _password.text,
            );
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Tidak bisa terhubung ke server. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardIndigo,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: AppColors.primary, size: 28),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 80),
                child: Text(
                  _register ? 'Buat akun baru' : 'Selamat datang',
                  style: GoogleFonts.quicksand(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 140),
                child: Text(
                  'Pantau risiko diabetes dengan penjelasan yang mudah dipahami. Data tetap di perangkatmu saat berbagi model.',
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              if (_register)
                FadeInUp(
                  delay: const Duration(milliseconds: 180),
                  child: _field(_name, 'Nama', Icons.person_outline_rounded),
                ),
              FadeInUp(
                delay: const Duration(milliseconds: 220),
                child: _field(_email, 'Email', Icons.mail_outline_rounded),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 280),
                child: _field(
                  _password,
                  'Kata sandi',
                  Icons.lock_outline_rounded,
                  obscure: true,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                FadeInUp(
                  child: Text(
                    _error!,
                    style: GoogleFonts.quicksand(
                        color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 340),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _register ? 'Daftar' : 'Masuk',
                            style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _register = !_register),
                  child: Text(
                    _register
                        ? 'Sudah punya akun? Masuk'
                        : 'Belum punya akun? Daftar',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
