# Conky Horizon

[Kembali ke galeri tema](../README.md#galeri-tema)

Tema lunar minimalis dengan jam tipografi besar bernuansa ivory, tanggal dan cuaca ringkas, serta enam metrik sistem dalam satu baris. Panel bawah berlatar gelap agar statistik tetap terbaca di atas permukaan bulan.

Menampilkan CPU, RAM tersedia, ruang disk, zram, swap SSD, suhu CPU, uptime, dan grafik singkat beban CPU.

## Kebutuhan

Ditujukan untuk Ubuntu/Debian dengan desktop GNOME, paling sesuai untuk layar 16:9. Transparansi dan penempatan dapat berbeda menurut compositor; pada Wayland, Conky memakai dukungan X11/XWayland yang tersedia. Dock, ikon, dan panel GNOME mengikuti konfigurasi desktop Anda.

Pasang dependensi:

```bash
sudo apt update
sudo apt install conky-all python3 fonts-dejavu-core x11-xserver-utils
```

Jalankan installer dari sesi desktop pengguna biasa, **tanpa `sudo`**.

## Pemasangan

Dari root repositori, masuk ke folder tema dan jalankan installer:

```bash
cd conky-horizon
python3 install.py
```

Jika memakai paket portabel, ekstrak lalu jalankan `python3 install.py` dari folder `Conky-Horizon`.

Installer mencadangkan konfigurasi Conky dan wallpaper sebelumnya di `~/.config/conky/Horizon-backups/`, menyalin tema ke `~/.config/conky/Horizon`, mengatur wallpaper dan autostart, lalu mengganti Conky yang sedang berjalan. Lebar layout mengikuti monitor utama melalui `xrandr`.

## Menjalankan ulang

```bash
~/.config/conky/Horizon/start.sh
```

## Memulihkan tampilan sebelumnya

Untuk mengembalikan wallpaper dan konfigurasi sebelum pemasangan terakhir:

```bash
python3 ~/.config/conky/Horizon/restore.py
```

## Data sistem dan cuaca

- Metrik sistem dibaca setiap tiga detik; cuaca diperbarui setiap 15 menit.
- RAM terpakai dihitung menggunakan `MemAvailable`, bukan hanya RAM kosong.
- Pemakaian swap zram dan jejak RAM fisiknya ditampilkan terpisah.
- Persentase disk menggunakan ruang yang tersedia bagi pengguna, mengikuti perhitungan `df`.
- Cuaca memakai [Open-Meteo](https://open-meteo.com/) dengan lokasi bawaan Malang. Jika data tidak tersedia atau lebih tua dari dua jam, widget menampilkan `WEATHER OFFLINE`.
- Ubah koordinat di `theme/metrics.py` dan label kota di renderer Lua sebelum memasang untuk mengganti lokasi cuaca.
- Suhu CPU bergantung pada sensor yang disediakan kernel. Jika zram tidak ada, nilainya ditampilkan nol.

## Paket portabel dan pengembangan

Unduh [Conky-Horizon-portable.tar.gz](dist/Conky-Horizon-portable.tar.gz). Lihat [PETUNJUK.txt](PETUNJUK.txt) untuk langkah pemasangan lengkap.

Setelah mengedit source, buat ulang paket dari folder tema:

```bash
python3 build-package.py
```

Mengedit source proyek tidak langsung mengubah salinan terpasang; jalankan kembali `python3 install.py` untuk menerapkannya.

## Struktur

| Lokasi | Kegunaan |
|---|---|
| `theme/Horizon.conf` | Konfigurasi Conky |
| `theme/horizon.lua` | Renderer Lua/Cairo |
| `theme/metrics.py` | Kolektor sistem dan cuaca |
| `theme/start.sh` | Peluncur dan deteksi lebar monitor utama |
| `theme/lunar-wallpaper.png` | Wallpaper |
| `install.py` / `restore.py` | Pemasangan, pencadangan, dan pemulihan |
| `build-package.py` / `dist/` | Pembuatan dan hasil paket portabel |

Wallpaper dibuat menggunakan ImageGen; prompt tersedia di [wallpaper-prompt.txt](theme/wallpaper-prompt.txt). Paket tidak menyertakan kredensial, log sesi, atau cadangan profil pengguna.
