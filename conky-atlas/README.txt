CONKY ATLAS
Tema topografi generatif: charcoal, kontur sage dan tembaga, jam serif di kiri bawah, metrik vertikal di kanan.

Source: conky-atlas/theme/
Pasang dari desktop tanpa sudo: python3 install.py
Pulihkan: python3 ~/.config/conky/Atlas/restore.py
Bangun paket: python3 build-package.py

Wallpaper dibuat secara deterministik dari kurva vektor menggunakan generate-wallpaper.py; SVG dan PNG disertakan. Kontur bersifat ilustratif, bukan peta medan geografis nyata. Untuk membuat ulang wallpaper diperlukan python3-cairo, hanya pada komputer pengembangan.

Metrik aktual setiap 3 detik: CPU, RAM tersedia, disk, swap SSD, zram, suhu CPU, uptime. Cuaca Open-Meteo untuk Malang setiap 15 menit. CPU sparkline menyimpan 60 sampel selama Conky berjalan. Dock dan panel GNOME tidak diubah. Lebar layout mengikuti monitor utama.
