# Conky Garuda Orbit

[Kembali ke galeri tema](../README.md#galeri-tema)

**Indonesia · retro · astronot · orbit.** Garuda Orbit adalah konsep misi antariksa fiktif dengan ilustrasi poster retro: astronot beraksen merah-putih dan batik, garis orbit emas, serta lengkung Bumi dan kepulauan Indonesia yang distilisasi. Wallpaper merupakan ilustrasi artistik, bukan foto misi atau peta geografis presisi.

Jam piksel, tanggal Indonesia, dan cuaca Malang menempati sisi kiri. CPU, RAM, SSD, dan lama menyala (uptime) berjajar di atas tanpa latar panel. Panel kiri juga memuat RAM tersedia, zram, swap SSD, ruang disk kosong, dan suhu CPU. Persentase RAM dan SSD menunjukkan ruang terpakai. Palet merah bata, putih gading, emas, dan hijau giok dipadukan dengan pemisah kawung; angka jam digambar melalui Cairo sehingga tidak memerlukan font piksel tambahan.

Tema ini statis dengan pembaruan metrik setiap tiga detik. Desktop aktif baru diganti setelah installer dijalankan.

## Kebutuhan

Ubuntu/Debian dengan desktop GNOME, paling sesuai untuk monitor 16:9. Transparansi dan penempatan dapat berbeda menurut compositor; pada Wayland diperlukan dukungan X11/XWayland untuk Conky. Dock, ikon, dan panel GNOME mengikuti konfigurasi desktop Anda.

```bash
sudo apt update
sudo apt install conky-all python3 fonts-dejavu-core x11-xserver-utils
```

## Pemasangan

Dari root repositori, jalankan dari sesi desktop pengguna biasa, tanpa `sudo`:

```bash
cd conky-garuda-orbit
python3 install.py
```

Jika memakai paket portabel, ekstrak lalu jalankan `python3 install.py` dari folder `Conky-GarudaOrbit`.

Installer mencadangkan wallpaper dan konfigurasi sebelumnya di `~/.config/conky/GarudaOrbit-backups/`, memasang salinan tema di `~/.config/conky/GarudaOrbit`, mengatur wallpaper dan autostart, lalu mengganti Conky yang sedang berjalan. Lebar layout mengikuti monitor utama melalui `xrandr`.

## Menjalankan ulang

```bash
~/.config/conky/GarudaOrbit/start.sh
```

## Memulihkan tampilan sebelumnya

```bash
python3 ~/.config/conky/GarudaOrbit/restore.py
```

## Data dan penyesuaian

- CPU, RAM, swap, disk, suhu, dan uptime dibaca setiap tiga detik.
- RAM terpakai dihitung berdasarkan `MemAvailable`.
- Alokasi swap zram dan jejak RAM fisiknya ditampilkan terpisah. Jika zram tidak tersedia, nilainya ditampilkan nol.
- Persentase disk mengikuti perhitungan `df`, berdasarkan ruang yang tersedia untuk pengguna.
- Cuaca [Open-Meteo](https://open-meteo.com/) memakai koordinat Malang dan diperbarui setiap 15 menit. Data yang tidak tersedia atau lebih tua dari dua jam ditandai `CUACA TIDAK TERSEDIA`.
- Untuk mengganti kota, ubah koordinat di `theme/metrics.py` dan label kota di `theme/garuda_orbit.lua` sebelum memasang.
- Jam mengikuti waktu lokal sistem. Label bawaan adalah `WAKTU INDONESIA BARAT`; sesuaikan label dalam `theme/garuda_orbit.lua` jika memakai zona waktu lain.
- Warna dan ornamen diatur di `theme/garuda_orbit.lua`; wallpaper tersedia sebagai berkas terpisah.
- Pembacaan suhu bergantung pada sensor kernel.

## Paket portabel dan pengembangan

Paket siap salin: [Conky-GarudaOrbit-portable.tar.gz](dist/Conky-GarudaOrbit-portable.tar.gz). Petunjuk ringkas ada di [PETUNJUK.txt](PETUNJUK.txt).

Setelah mengedit source, buat ulang paket dari folder tema:

```bash
python3 build-package.py
```

Mengedit source proyek tidak langsung mengubah salinan terpasang; jalankan kembali installer untuk menerapkannya.

## Struktur

| Lokasi | Kegunaan |
|---|---|
| `theme/GarudaOrbit.conf` | Konfigurasi Conky |
| `theme/garuda_orbit.lua` | Jam, tanggal, ornamen, dan metrik melalui Lua/Cairo |
| `theme/metrics.py` | Kolektor metrik dan cuaca |
| `theme/start.sh` | Peluncur dan deteksi lebar monitor |
| `theme/garuda-orbit-wallpaper.png` | Poster astronot retro dan orbit Indonesia |
| `install.py` / `restore.py` | Pemasangan, cadangan, dan pemulihan |
| `build-package.py` / `dist/` | Pembuatan dan hasil paket portabel |

Wallpaper dibuat dengan ImageGen; prompt tersimpan di [wallpaper-prompt.txt](theme/wallpaper-prompt.txt). Paket tidak menyertakan kredensial, log sesi, atau cadangan pribadi.
