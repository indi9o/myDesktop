# Conky Nusantara

[Kembali ke galeri tema](../README.md#galeri-tema)

Tema desktop bernuansa Indonesia dengan hijau hutan, merah bata, dan emas. Latar gunung berapi merupakan ilustrasi artistik yang terinspirasi Jawa Timur; ornamen empat kelopak terinspirasi motif kawung. Tema ini tidak dimaksudkan sebagai peta atau dokumentasi lokasi tertentu.

Jam memakai pemisah titik, tanggal dan keterangan cuaca berbahasa Indonesia, serta label metrik yang ringkas. Panel bawah menampilkan beban CPU, RAM tersedia, ruang disk, zram, dan swap SSD; suhu CPU dan lama menyala berada di dekat jam. Tema ini statis dan tidak mengubah mode Atlas Live yang mungkin sedang dipakai sampai installer dijalankan.

## Kebutuhan

Ubuntu/Debian dengan desktop GNOME, paling sesuai untuk monitor 16:9. Transparansi dan penempatan dapat berbeda menurut compositor; pada Wayland diperlukan dukungan X11/XWayland untuk Conky. Dock, ikon, dan panel GNOME mengikuti konfigurasi desktop Anda.

```bash
sudo apt update
sudo apt install conky-all python3 fonts-dejavu-core x11-xserver-utils
```

## Pemasangan

Dari root repositori, jalankan dari sesi desktop pengguna biasa, tanpa `sudo`:

```bash
cd conky-nusantara
python3 install.py
```

Jika memakai paket portabel, ekstrak lalu jalankan `python3 install.py` dari folder `Conky-Nusantara`.

Installer mencadangkan wallpaper dan konfigurasi sebelumnya di `~/.config/conky/Nusantara-backups/`, memasang salinan tema di `~/.config/conky/Nusantara`, mengatur wallpaper dan autostart, lalu mengganti Conky yang sedang berjalan. Lebar layout mengikuti monitor utama melalui `xrandr`.

## Menjalankan ulang

```bash
~/.config/conky/Nusantara/start.sh
```

## Memulihkan tampilan sebelumnya

```bash
python3 ~/.config/conky/Nusantara/restore.py
```

## Data dan penyesuaian

- CPU, RAM, swap, disk, suhu, dan uptime dibaca setiap tiga detik.
- RAM terpakai dihitung berdasarkan `MemAvailable`.
- Alokasi swap zram dan jejak RAM fisiknya ditampilkan terpisah. Jika zram tidak tersedia, nilainya ditampilkan nol.
- Persentase disk mengikuti perhitungan `df`, berdasarkan ruang yang tersedia untuk pengguna.
- Cuaca [Open-Meteo](https://open-meteo.com/) memakai koordinat Malang dan diperbarui setiap 15 menit. Data yang tidak tersedia atau lebih tua dari dua jam ditandai `CUACA TIDAK TERSEDIA`.
- Untuk mengganti kota, ubah koordinat di `theme/metrics.py` dan label kota di `theme/nusantara.lua` sebelum memasang.
- Jam mengikuti waktu lokal sistem. Label bawaan adalah `WIB`; sesuaikan label dalam `theme/nusantara.lua` jika memakai zona waktu lain.
- Warna dan ornamen diatur di `theme/nusantara.lua`; wallpaper tersedia sebagai berkas terpisah.
- Pembacaan suhu bergantung pada sensor kernel.

## Paket portabel dan pengembangan

Paket siap salin: [Conky-Nusantara-portable.tar.gz](dist/Conky-Nusantara-portable.tar.gz). Petunjuk ringkas ada di [PETUNJUK.txt](PETUNJUK.txt).

Setelah mengedit source, buat ulang paket dari folder tema:

```bash
python3 build-package.py
```

Mengedit source proyek tidak langsung mengubah salinan terpasang; jalankan kembali installer untuk menerapkannya.

## Struktur

| Lokasi | Kegunaan |
|---|---|
| `theme/Nusantara.conf` | Konfigurasi Conky |
| `theme/nusantara.lua` | Jam, tanggal, ornamen, dan metrik melalui Lua/Cairo |
| `theme/metrics.py` | Kolektor metrik dan cuaca |
| `theme/start.sh` | Peluncur dan deteksi lebar monitor |
| `theme/volcano-wallpaper.png` | Ilustrasi gunung berapi |
| `install.py` / `restore.py` | Pemasangan, cadangan, dan pemulihan |
| `build-package.py` / `dist/` | Pembuatan dan hasil paket portabel |

Wallpaper dibuat dengan ImageGen; prompt tersimpan di [wallpaper-prompt.txt](theme/wallpaper-prompt.txt). Paket tidak menyertakan kredensial, log sesi, atau cadangan pribadi.
