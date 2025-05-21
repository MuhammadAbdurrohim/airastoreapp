# Aira Store App (Flutter)

## Overview
Aira Store adalah aplikasi mobile berbasis Flutter yang menyediakan fitur e-commerce dengan kemampuan live streaming. Pengguna dapat berbelanja produk, menonton live streaming, dan berinteraksi dengan penjual secara real-time.

## Persyaratan Sistem
- Android 5.0+ atau iOS 11+
- RAM minimal 2GB
- Storage minimal 100MB
- Kamera & mikrofon (untuk fitur live streaming)
- Koneksi internet stabil

## Dependencies dan Versi

### Core
- Flutter SDK: '>=3.0.0 <4.0.0'
- provider: ^6.1.1 (state management)
- http: ^1.1.0 (network requests)
- shared_preferences: ^2.2.2 (local storage)
- flutter_secure_storage: ^9.0.0 (secure storage)
- path_provider: ^2.1.1 (file system)

### UI/UX
- cupertino_icons: ^1.0.6
- flutter_svg: ^2.0.9
- cached_network_image: ^3.3.0
- google_fonts: ^6.1.0
- flutter_native_splash: ^2.3.8
- flutter_launcher_icons: ^0.13.1

### Live Streaming
- zego_uikit_prebuilt_live_streaming: ^2.6.1

### Firebase & Notifications
- firebase_core: ^2.24.2
- firebase_messaging: ^14.7.10
- flutter_local_notifications: ^16.3.0

### Utils
- intl: ^0.19.0 (internationalization)
- url_launcher: ^6.2.2
- image_picker: ^1.0.4
- permission_handler: ^11.0.1
- connectivity_plus: ^5.0.2
- package_info_plus: ^4.2.0
- device_info_plus: ^9.1.1

### Development
- flutter_lints: ^3.0.1
- flutter_test: sdk: flutter

## Fitur Utama

### Autentikasi & Profil
- Login dan registrasi pengguna
- Manajemen profil pengguna
- Riwayat pesanan
- Pengaturan alamat pengiriman
- Pengaturan notifikasi

### Belanja
1. Katalog Produk
   - Pencarian produk
   - Filter berdasarkan kategori
   - Sorting berdasarkan harga/rating
   - Detail produk lengkap

2. Keranjang & Checkout
   - Tambah/hapus produk
   - Update jumlah
   - Pilih alamat pengiriman
   - Pilih metode pembayaran
   - Upload bukti pembayaran

3. Pesanan
   - Status pesanan realtime
   - Detail pesanan
   - Riwayat pesanan
   - Komplain pesanan

### Live Streaming
1. Menonton Live
   - List live streaming aktif
   - Detail streamer
   - Produk yang dipromosikan
   - Interaksi via komentar
   - Reaction/emoji

2. Fitur Saat Live
   - Chat realtime
   - Lihat produk yang dipin
   - Beli produk langsung
   - Gunakan voucher khusus live
   - Notifikasi live dimulai

## Panduan Penggunaan

### Registrasi & Login
1. Buka aplikasi
2. Pilih "Daftar" untuk pengguna baru
3. Isi form registrasi
4. Verifikasi email/nomor HP
5. Login dengan akun yang dibuat

### Belanja Produk
1. Browse produk di halaman utama
2. Gunakan fitur pencarian/filter
3. Pilih produk untuk lihat detail
4. Tambahkan ke keranjang
5. Lakukan checkout
6. Pilih pengiriman & pembayaran
7. Upload bukti pembayaran
8. Tunggu konfirmasi

### Menonton Live Streaming
1. Buka tab "Live"
2. Pilih live streaming aktif
3. Tonton dan berinteraksi via chat
4. Lihat produk yang dipin
5. Klik produk untuk beli langsung
6. Gunakan voucher khusus live
7. Follow streamer favorit

### Manajemen Pesanan
1. Buka tab "Pesanan"
2. Lihat status pesanan
3. Klik untuk detail lengkap
4. Upload bukti pembayaran
5. Ajukan komplain jika ada masalah
6. Konfirmasi penerimaan barang

## Halaman & Fitur

### Home Screen
- Banner promo
- Kategori produk
- Produk rekomendasi
- Live streaming aktif
- Pencarian produk

### Product Detail
- Foto produk
- Deskripsi lengkap
- Variasi produk
- Stok tersedia
- Rating & review
- Tombol beli/keranjang

### Cart Screen
- List produk
- Jumlah & subtotal
- Voucher/promo
- Total pembayaran
- Tombol checkout

### Checkout Screen
- Form alamat
- Pilihan kurir
- Metode pembayaran
- Rincian biaya
- Konfirmasi pesanan

### Order History
- List semua pesanan
- Filter berdasar status
- Detail per pesanan
- Upload bukti bayar
- Tracking pengiriman

### Live Streaming
- Video stream
- Chat realtime
- List produk
- Informasi streamer
- Tombol interaksi

### Profile Screen
- Info pribadi
- Alamat tersimpan
- Metode pembayaran
- Pengaturan notifikasi
- Riwayat aktivitas

## Troubleshooting

### Masalah Koneksi
- Cek koneksi internet
- Restart aplikasi
- Clear cache jika perlu

### Live Streaming
- Pastikan koneksi stabil
- Izinkan akses kamera/mic
- Gunakan WiFi untuk kualitas baik

### Pembayaran
- Screenshot bukti pembayaran
- Simpan nomor pesanan
- Hubungi CS jika bermasalah

## Kontak & Bantuan
- Email: support@airastore.com
- WhatsApp: +62xxx
- Live chat dalam aplikasi
- FAQ di menu bantuan

## Keamanan
- Enkripsi data
- Pembayaran aman
- Proteksi data pribadi
- Verifikasi 2 langkah

## Pembaruan
- Cek update di Play Store/App Store
- Aktifkan auto-update
- Backup data penting
- Baca changelog
