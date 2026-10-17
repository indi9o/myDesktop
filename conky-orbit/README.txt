CONKY ORBIT
Tema desktop retro astronaut dengan jam piksel dan metrik sistem.

LOKASI PROYEK
/home/alan/Documents/03Resource/myDesktop/conky-orbit

STRUKTUR
  theme/Orbit.conf            Konfigurasi Conky
  theme/orbit.lua             Gambar jam, tanggal, dan panel metrik menggunakan Cairo
  theme/metrics.py            Pengumpul CPU, RAM, swap, zram, disk, suhu, dan cuaca
  theme/start.sh              Peluncur tema dan kolektor; deteksi lebar monitor utama
  theme/astronaut-wallpaper.png  Wallpaper buatan ImageGen
  theme/wallpaper-prompt.txt  Catatan prompt wallpaper
  install.py                 Installer pengguna + cadangan wallpaper dan Conky sebelumnya
  restore.py                 Pemulihan konfigurasi sebelum pemasangan
  build-package.py           Membuat ulang arsip portabel
  dist/                      Paket siap disalin ke komputer lain
  PETUNJUK.txt               Petunjuk pemasangan lengkap dan batasan platform

PENGEMBANGAN
Edit source di folder ini, lalu buat paket ulang:
  python3 build-package.py

Untuk menerapkan versi source ini di komputer sendiri:
  python3 install.py
Jalankan dari desktop pengguna biasa, jangan dengan sudo.

KONFIGURASI AKTIF
Desktop saat ini memakai salinan di ~/.config/conky/Orbit.
Mengedit source proyek tidak langsung mengubah tampilan aktif; jalankan installer
untuk menerapkan perubahan. Installer mencadangkan konfigurasi yang diganti.

PLATFORM
Ubuntu/Debian GNOME dengan conky-all, Python 3, DejaVu Sans Mono, dan xrandr.
Wallpaper dan jam tersedia offline. Cuaca memerlukan akses HTTPS ke Open-Meteo.
Lokasi cuaca bawaan: Malang; koordinat di theme/metrics.py, label kota di theme/orbit.lua.
Dock, ikon, dan panel GNOME tidak diubah.

PRIVASI
Source dan paket tidak menyertakan kredensial, log sesi, atau cadangan profil pengguna.
Source tema Pleione sebelumnya tetap berada di ~/.config/conky/Pleione.
