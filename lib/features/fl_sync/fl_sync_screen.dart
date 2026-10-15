import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../shared/widgets/fade_in.dart';
import 'services/fl_sync_provider.dart';
import 'services/fl_sync_service.dart';

class FlSyncScreen extends ConsumerStatefulWidget {
  const FlSyncScreen({super.key});

  @override
  ConsumerState<FlSyncScreen> createState() => _FlSyncScreenState();
}

class _FlSyncScreenState extends ConsumerState<FlSyncScreen> {
  @override
  void initState() {
    super.initState();
    // Tampilkan info model global (tanpa mengunduh ulang tiap rebuild).
    Future.microtask(() => ref.read(flSyncProvider.notifier).refreshModel());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(flSyncProvider);
    final notifier = ref.read(flSyncProvider.notifier);
    final enough = state.records.length >= kMinLocalRecords;

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
                  'Sinkronisasi model',
                  style: GoogleFonts.quicksand(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              FadeInUp(
                delay: const Duration(milliseconds: 60),
                child: Text(
                  'Model dilatih di perangkat. Yang dikirim hanya pembaruan bobot ber-noise, bukan data kesehatan.',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: _HeroCard(
                  busy: state.busy,
                  status: state.status,
                  canSync: enough && !state.busy,
                  onSync: notifier.runSync,
                ),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: GoogleFonts.quicksand(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 140),
                child: _LocalDataCard(
                  count: state.records.length,
                  enough: enough,
                  busy: state.busy,
                  onLoadDemo: () => notifier.loadDemoData(),
                  onClear: notifier.clearData,
                ),
              ),
              if (state.report != null) ...[
                const SizedBox(height: 16),
                FadeInUp(
                  child: _ReportCard(
                    report: state.report!,
                    busy: state.busy,
                    onAggregate: notifier.aggregateNow,
                  ),
                ),
              ],
              if (state.model != null) ...[
                const SizedBox(height: 16),
                FadeInUp(
                  delay: const Duration(milliseconds: 180),
                  child: _ModelCard(model: state.model!),
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

class _Card extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Card({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.quicksand(
                  fontSize: 13, color: AppColors.textSecondaryLight),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }
}

class _Check extends StatelessWidget {
  final String label;
  final bool ok;
  const _Check(this.label, this.ok);

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.success : AppColors.error;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: GoogleFonts.quicksand(
                    fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

String _short(String hash) =>
    hash.length <= 14 ? hash : '${hash.substring(0, 8)}...${hash.substring(hash.length - 6)}';

class _HeroCard extends StatelessWidget {
  final bool busy;
  final String status;
  final bool canSync;
  final VoidCallback onSync;
  const _HeroCard({
    required this.busy,
    required this.status,
    required this.canSync,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            busy
                ? (status.isEmpty ? 'Bekerja...' : status)
                : 'Latih di perangkat lalu kirim pembaruan model yang aman.',
            style: GoogleFonts.quicksand(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          if (busy) ...[
            const SizedBox(height: 14),
            const LinearProgressIndicator(
              backgroundColor: Colors.white24,
              color: Colors.white,
              minHeight: 4,
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: canSync ? onSync : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                disabledBackgroundColor: Colors.white24,
                disabledForegroundColor: Colors.white70,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text('Latih & kirim pembaruan',
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocalDataCard extends StatelessWidget {
  final int count;
  final bool enough;
  final bool busy;
  final VoidCallback onLoadDemo;
  final VoidCallback onClear;
  const _LocalDataCard({
    required this.count,
    required this.enough,
    required this.busy,
    required this.onLoadDemo,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Data lokal',
      children: [
        _Row('Catatan berlabel', '$count (min. $kMinLocalRecords)'),
        Text(
          enough
              ? 'Cukup untuk melatih. Data tetap di perangkat ini.'
              : 'Belum cukup untuk melatih. Muat data contoh untuk demo.',
          style: GoogleFonts.quicksand(
              fontSize: 12, color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: busy ? null : onLoadDemo,
                child: Text('Muat 50 data contoh',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: (busy || count == 0) ? null : onClear,
              child: Text('Hapus',
                  style: GoogleFonts.quicksand(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Data contoh diambil dari dataset server (demo), bukan data pasien nyata.',
          style: GoogleFonts.quicksand(
              fontSize: 11, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final SyncReport report;
  final bool busy;
  final VoidCallback onAggregate;
  const _ReportCard({
    required this.report,
    required this.busy,
    required this.onAggregate,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Pembaruan terkirim',
      children: [
        _Check('Update diterima server (hash & tanda tangan valid)', true),
        _Check('Hash update tercatat di ledger', report.auditVerified),
        _Check(
          report.aggregated
              ? 'Ronde ${report.roundId} sudah diagregasi'
              : 'Menunggu klien lain (${report.pendingInRound}/${report.minClients})',
          report.aggregated,
        ),
        const SizedBox(height: 6),
        _Row('Ronde', '${report.roundId}'),
        _Row('Contoh dipakai', '${report.numExamples}'),
        _Row('Hash update', _short(report.updateHash)),
        if (report.clientEpsilon != null)
          _Row('ε kumulatif (δ=1e-5)', report.clientEpsilon!.toStringAsFixed(2)),
        if (!report.aggregated) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: busy ? null : onAggregate,
              child: Text('Paksa agregasi sekarang (demo)',
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold, color: AppColors.primary)),
            ),
          ),
        ],
      ],
    );
  }
}

class _ModelCard extends StatelessWidget {
  final GlobalModel model;
  const _ModelCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Model global',
      children: [
        const _Check('Hash cocok dengan byte yang diterima', true),
        const _Check('Terverifikasi di ledger', true),
        const SizedBox(height: 6),
        _Row('Versi / ronde berikutnya', 'v${model.modelVersion} / ${model.roundId}'),
        _Row('Hash', _short(model.hash)),
        _Row('Algoritma', model.algo),
        _Row(
          'Privasi diferensial',
          model.dpEnabled
              ? 'C=${model.clipNorm}, σ=${model.noiseMultiplier}'
              : 'nonaktif',
        ),
        if (model.dpEnabled && model.epsilonPerRound != null)
          _Row('ε per ronde', model.epsilonPerRound!.toStringAsFixed(2)),
        if (model.dataSource == 'synthetic')
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Server memakai data sintetis. Hasil hanya untuk uji alur, bukan untuk naskah.',
              style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning),
            ),
          ),
      ],
    );
  }
}
