import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'fl_sync_service.dart';

/// Penyimpanan data lokal berlabel yang dipakai melatih model di perangkat.
/// Data ini TIDAK PERNAH dikirim ke server; yang dikirim hanya delta bobot ber-DP.
class LocalDataStore {
  static const String _key = 'fl_local_records_v1';
  static const int maxRecords = 500;

  Future<List<LabeledRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return [
        for (final e in list) LabeledRecord.fromJson(e as Map<String, dynamic>)
      ];
    } catch (_) {
      return []; // data rusak -> mulai bersih
    }
  }

  Future<void> save(List<LabeledRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final capped = records.length > maxRecords
        ? records.sublist(records.length - maxRecords)
        : records;
    await prefs.setString(
      _key,
      jsonEncode([for (final r in capped) r.toJson()]),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
