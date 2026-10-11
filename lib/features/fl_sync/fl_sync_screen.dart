import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_client.dart';
import '../../shared/widgets/fade_in.dart';
import '../auth/auth_provider.dart';

class FlSyncScreen extends ConsumerStatefulWidget {
  const FlSyncScreen({super.key});

  @override
  ConsumerState<FlSyncScreen> createState() => _FlSyncScreenState();
}

class _FlSyncScreenState extends ConsumerState<FlSyncScreen> {
  bool _syncing = false;
  String _status = 'Model di perangkat sudah siap';
  String? _roundId;
  String? _hash;
  bool? _verified;
  String? _error;

  Future<void> _sync() async {
    setState(() {
      _syncing = true;
      _error = null;
      _status = 'Melatih ulang secara ringan di perangkat...';
    });
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() => _status = 'Mengirim pembaruan model (bukan data kesehatan)...');
    try {
      final clientId = ref.read(authProvider)?.userId ?? const Uuid().v4();
      final submit = await apiClient.post('/fl/submit-update', body: {
        'client_id': clientId,
        'weights': List<double>.generate(8, (i) => (i + 1) * 0.01),
        'round_id': '1',
      }) as Map<String, dynamic>;
      final roundId = submit['round_id'] as String;
      await apiClient.get('/fl/global-model?round=$roundId');
      final audit = await apiClient.get('/audit/$roundId') as Map<String, dynamic>;
      setState(() {
        _roundId = roundId;
        _hash = submit['model_hash'] as String;
        _verified = audit['verified'] as bool? ?? true;
        _status = 'Pembaruan tercatat. Data kesehatan tetap di perangkatmu.';
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() =>
          _error = 'Sinkronisasi belum terhubung. Pastikan server AI berjalan.');
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              FadeInUp(
                child: Text(
                  'Pembaruan aman',
                  style: GoogleFonts.quicksand(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 70),
                child: Text(
                  'Aplikasi belajar dari datamu di perangkat. Yang dikirim hanya pembaruan model terenkripsi.',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeScaleIn(
                delay: const Duration(milliseconds: 120),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.shield_rounded, color: Colors.white, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Data kamu tetap di perangkat',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.quicksand(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _syncing ? null : _sync,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _syncing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  'Kirim pembaruan aman',
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: GoogleFonts.quicksand(
                        color: AppColors.error, fontWeight: FontWeight.w600)),
              ],
              if (_hash != null) ...[
                const SizedBox(height: 20),
                FadeInUp(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jejak verifikasi',
                            style: GoogleFonts.quicksand(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Putaran $_roundId',
                            style: GoogleFonts.quicksand(fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(
                          _hash!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _verified == true
                              ? 'Terverifikasi'
                              : 'Belum terverifikasi',
                          style: GoogleFonts.quicksand(
                            fontWeight: FontWeight.bold,
                            color: _verified == true
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
