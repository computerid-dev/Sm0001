# Study Mate (SM) — Teman Belajar Digital

Aplikasi pendamping pelajar Android, dibangun pakai **Flutter** biar hasil akhirnya
1 file APK tunggal, ringan, dan bisa dipakai offline untuk fitur utamanya.

- Package name: `com.studymate.sm.cid`
- Versi: `1.0.0`
- Developer: Nugroho Yuli Rahmadhani — CID Studio

## Fitur yang sudah dibuat (sesuai spesifikasi kamu)
1. Kategori (CRUD)
2. Pelajaran (CRUD + Edit + Detail)
3. Dashboard ringkasan harian
4. PR / Tugas (dengan filter status & mapel)
5. Catatan Keuangan Sekolah (uang sangu harian)
6. Ujian / Ulangan
7. Backup Data ke JSON
8. Import Data dari JSON (dengan konfirmasi sebelum menimpa data lama)
9. Info Developer & Info Aplikasi
10. Jadwal Pelajaran (per hari, tab Senin–Minggu)
11. Catatan Materi
12. Kalender Akademik
13. Target Belajar (dengan progress bar)
14. Pengaturan (tema, nama pengguna, API key, backup/import, reset data)
15. Edit Pelajaran
16. Detail Pelajaran
17. AI Asisten (Gemini `gemini-flash-latest` via Google AI Studio, API key milik pengguna sendiri)

Semua data disimpan **lokal di perangkat** (SharedPreferences), tidak ada server / akun.

## ⚠️ Kenapa APK tidak langsung disertakan di sini?

Compile APK Android butuh Android SDK + Gradle + Java resmi yang **tidak tersedia**
di lingkungan pembuatan file ini (tidak ada Android SDK, dan akses internet dimatikan).
Supaya APK yang kamu pakai benar-benar valid dan tidak error, proses compile
dilakukan otomatis lewat **GitHub Actions** (bukan "Google workflow", karena Google
sendiri tidak punya layanan bernama itu — GitHub Actions inilah yang biasa dipakai
untuk auto-build APK dari source code).

## Cara mendapatkan file APK

1. **Buat repository baru di GitHub** (bisa privat atau publik), lalu upload/push
   seluruh isi folder project ini ke branch `main`.
   ```bash
   git init
   git add .
   git commit -m "Initial commit - Study Mate"
   git branch -M main
   git remote add origin https://github.com/USERNAME/study-mate.git
   git push -u origin main
   ```
2. Buka tab **Actions** di repo GitHub kamu → workflow **"Build Study Mate APK"**
   akan otomatis berjalan setiap ada push ke `main` (atau klik **Run workflow**
   untuk menjalankan manual).
3. Tunggu sampai proses selesai (biasanya 5–10 menit). Setelah selesai:
   - Buka run yang barusan selesai → bagian **Artifacts** → download
     `StudyMate-v1.0.0.zip` → di dalamnya ada **1 file APK utama**:
     `StudyMate-v1.0.0.apk`.
   - Atau cek tab **Releases** di repo (workflow otomatis membuat release baru
     berisi APK yang sama).
4. Pindahkan file `.apk` itu ke HP Android kamu, lalu install (aktifkan
   "Izinkan dari sumber ini / Install unknown apps" kalau diminta).
5. Icon Study Mate (logo hijau-navy yang kamu kasih) akan otomatis muncul
   sebagai icon aplikasi di HP setelah instalasi — ini dihasilkan otomatis
   lewat step **"Generate icon aplikasi"** di workflow (paket
   `flutter_launcher_icons`) yang mengambil gambar dari
   `assets/icon/app_icon.png`.

## Catatan soal AI Asisten (Gemini)

- User perlu isi API key Gemini pribadi (gratis) dari **Google AI Studio**
  di menu **Pengaturan**. Kalau belum diisi, tombol/fitur AI Asisten akan
  menampilkan pesan untuk mengisi API key dulu (sesuai permintaanmu).
- Model yang dipakai: `gemini-flash-latest`.
- AI diarahkan lewat system instruction supaya berperan sebagai **tutor**,
  bukan mesin jawaban instan — persis sesuai batasan yang kamu tulis di spek.

## Menjalankan / mengetes secara lokal (opsional, kalau kamu sudah punya Flutter SDK)

```bash
flutter pub get
flutter run
```

Untuk build APK manual di komputer sendiri:
```bash
flutter build apk --release
```
File hasilnya ada di `build/app/outputs/flutter-apk/app-release.apk`.

## Struktur folder penting

```
lib/
  main.dart              # entry point & navigasi
  models.dart            # semua model data
  store.dart             # state + persistence + backup/import JSON
  theme.dart             # warna & tema (navy + hijau, sesuai logo)
  screens/                # 12 layar fitur
assets/icon/app_icon.png  # sumber icon aplikasi
.github/workflows/
  build-apk.yml           # workflow auto-build APK + icon
```
