CONKY ATLAS
Tema topografi generatif: charcoal, kontur sage dan tembaga, jam serif di kiri bawah, metrik vertikal di kanan.

ATLAS LIVE
Pasang animasi Lua/Cairo: python3 install.py --live
Pemasangan menyimpan cadangan dan mengaktifkan animasi saat login.
Gerakan: kontur bergeser perlahan, pemindai tembaga, tiga titik survei.
Animasi memakai 8 fps (2 fps saat baterai menurut deteksi Conky); metrik dan
riwayat CPU tetap diperbarui setiap 3 detik. Wallpaper PNG didekode sekali lalu
dipakai ulang di memori. Tidak memerlukan pemutar video atau browser tambahan.

Beralih mode setelah terpasang:
  ~/.config/conky/Atlas/start.sh --static
  ~/.config/conky/Atlas/start.sh --live
Perintah ini mengganti mode sesi berjalan; untuk menyimpan mode saat login,
jalankan installer dengan --live atau tanpa flag untuk mode statis.

Source: conky-atlas/theme/
Pasang dari desktop tanpa sudo: python3 install.py
Pulihkan: python3 ~/.config/conky/Atlas/restore.py
Bangun paket: python3 build-package.py

Wallpaper dibuat secara deterministik dari kurva vektor menggunakan generate-wallpaper.py; SVG dan PNG disertakan. Kontur bersifat ilustratif, bukan peta medan geografis nyata. Untuk membuat ulang wallpaper diperlukan python3-cairo, hanya pada komputer pengembangan.

Metrik aktual setiap 3 detik: CPU, RAM tersedia, disk, swap SSD, zram, suhu CPU, uptime. Cuaca Open-Meteo untuk Malang setiap 15 menit. CPU sparkline menyimpan 60 sampel selama Conky berjalan. Dock dan panel GNOME tidak diubah. Lebar layout mengikuti monitor utama.
