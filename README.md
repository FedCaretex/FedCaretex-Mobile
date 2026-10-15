# FedCaretex Mobile

Aplikasi Flutter untuk skrining risiko Diabetes Mellitus Tipe 2 berbasis
Federated Learning, Differential Privacy, audit trail blockchain, dan SHAP eksak.
Backend: [FedCaretex-BackendAI](https://github.com/FedCaretex/FedCaretex-BackendAI).

Butuh Flutter 3.27+ (kode memakai `Color.withValues`).

## Menjalankan

1. Jalankan backend (di repo backend):

   ```bash
   pip install -r requirements.txt
   # isi data asli agar model tidak dilatih dari data sintetis:
   #   DATASET_CSV=data/diabetes_prediction_dataset.csv
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```

2. Jalankan aplikasi:

   ```bash
   flutter pub get
   flutter run                                                    # emulator Android -> http://10.0.2.2:8000
   flutter run --dart-define=API_BASE_URL=http://<IP-laptop>:8000 # HP fisik (satu Wi-Fi)
   ```

3. Masuk dengan akun demo `demo@fedcaretex.ai` / `demo123`, atau "Lanjut tanpa akun".

## Alur yang terhubung ke backend

| Fitur | Endpoint | Catatan |
|---|---|---|
| Login / daftar | `POST /auth/login`, `/auth/register` | |
| Prediksi (mode perangkat) | `GET /fl/global-model` | Model diunduh, **hash dan ledger diverifikasi**, lalu inferensi + SHAP dihitung di HP. Data klinis tidak dikirim. |
| Prediksi (mode server) | `POST /predict`, `GET /history/{id}` | Pembanding / demo |
| Sinkronisasi FL | `POST /fl/register-client`, `GET /fl/global-model`, `POST /fl/submit-update`, `GET /audit/verify` | Latih lokal → delta → DP (clip + noise) → FLM1 → SHA-256 → Ed25519 |
| Data contoh (demo) | `GET /dataset/random` | Mengisi form / data lokal saat demo |

Kontrak byte-per-byte (encoding 15 kolom, FLM1, hash, tanda tangan) diuji lewat
`flutter test` (`test/engine_parity_test.dart`) terhadap nilai dari implementasi Python.

## Keterbatasan yang perlu dicatat di naskah

- Seed kunci Ed25519 disimpan di SharedPreferences (tidak terenkripsi). Untuk produksi pindahkan ke Keystore/Keychain.
- Riwayat prediksi mode perangkat hanya di memori.
- Server tidak dapat membuktikan klien benar-benar menerapkan DP (lihat README backend).
