# Conky Atlas

[Kembali ke galeri tema](../README.md#galeri-tema)

Tema topografi generatif dengan palet charcoal–sage–tembaga, jam serif di kiri bawah, dan panel statistik vertikal di kanan. Kontur bersifat ilustratif, bukan peta medan geografis nyata.

Tersedia dua mode: **Atlas statis** dan **Atlas Live**, yang menambahkan gerakan pada latar. Panel menampilkan CPU, RAM tersedia, disk, zram, swap SSD, suhu CPU, dan riwayat beban CPU. Tanggal, cuaca Malang, serta uptime melengkapi tampilan.

## Kebutuhan

Ditujukan untuk Ubuntu/Debian dengan desktop GNOME, paling sesuai untuk layar 16:9. Transparansi dan penempatan dapat berbeda menurut compositor; pada Wayland, Conky memakai dukungan X11/XWayland yang tersedia. Dock, ikon, dan panel GNOME mengikuti konfigurasi desktop Anda.

Pasang dependensi:

```bash
sudo apt update
sudo apt install conky-all python3 fonts-dejavu-core x11-xserver-utils
```

Jalankan installer dari sesi desktop pengguna biasa, **tanpa `sudo`**.

## Atlas Live

Kontur bergeser perlahan dengan pemindai tembaga dan tiga titik survei; jam dan panel statistik tetap diam. Artwork didekode sekali dan digunakan ulang dari memori, tanpa pemutar video atau browser tambahan.

Target animasi adalah 8 fps, dengan interval lebih lambat saat Conky mendeteksi penggunaan baterai. Pembacaan metrik dan pengambilan sampel riwayat CPU tetap setiap tiga detik; grafik menampung 60 sampel.

Dari root repositori, pasang dan aktifkan animasi, termasuk saat login:

```bash
cd conky-atlas
python3 install.py --live
```

Jika memakai paket portabel, ekstrak lalu jalankan `python3 install.py --live` dari folder `Conky-Atlas`.

[Pratinjau animasi](../docs/images/conky-atlas-live-preview.gif) mengambil dua frame per detik agar file lebih kecil. Pada sampel singkat 12 detik di desktop pengembangan, proses Conky memakai sekitar 48,8 MiB RAM dan 2,42% dari satu inti CPU. Pengukuran ini tidak mencakup compositor/GPU dan bukan jaminan untuk perangkat lain. Lihat [catatan pengukuran](LIVE-BENCHMARK.txt).

## Atlas statis

Dari root repositori:

```bash
cd conky-atlas
python3 install.py
```

Jika memakai paket portabel, ekstrak lalu jalankan `python3 install.py` dari folder `Conky-Atlas`.

## Beralih mode

Setelah terpasang, gunakan salah satu perintah berikut:

```bash
~/.config/conky/Atlas/start.sh --static
~/.config/conky/Atlas/start.sh --live
```

Perintah tersebut mengganti mode pada sesi berjalan. Untuk menyimpan pilihan saat login, jalankan kembali installer dengan `--live` untuk animasi atau tanpa flag untuk mode statis.

## Pemasangan dan pemulihan

Installer memasang salinan tema ke `~/.config/conky/Atlas`, mengatur wallpaper dan autostart, lalu mengganti Conky yang sedang berjalan. Wallpaper dan konfigurasi sebelumnya dicadangkan di `~/.config/conky/Atlas-backups/`.

Untuk memulihkan tampilan sebelum pemasangan terakhir:

```bash
python3 ~/.config/conky/Atlas/restore.py
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

Unduh [Conky-Atlas-portable.tar.gz](dist/Conky-Atlas-portable.tar.gz). Petunjuk ekstraksi dan pemasangan tersedia di [PETUNJUK.txt](PETUNJUK.txt).

Dari folder tema, buat ulang paket setelah mengubah source:

```bash
python3 build-package.py
```

Wallpaper berasal dari kurva vektor deterministik. [Generator](generate-wallpaper.py), [SVG](theme/topography-wallpaper.svg), dan [PNG](theme/topography-wallpaper.png) disertakan. Untuk membuat ulang wallpaper pada komputer pengembangan:

```bash
sudo apt install python3-cairo
python3 generate-wallpaper.py
```

Pemasangan tema tidak memerlukan `python3-cairo` karena PNG sudah tersedia. Mengedit source proyek tidak langsung mengubah salinan terpasang; jalankan kembali installer untuk menerapkannya.

## Struktur

| Lokasi | Kegunaan |
|---|---|
| `theme/Atlas.conf` | Konfigurasi mode statis |
| `theme/AtlasLive.conf` | Konfigurasi mode animasi |
| `theme/atlas.lua` | Renderer jam, tanggal, panel, dan grafik CPU |
| `theme/atlas-live.lua` | Animasi latar melalui Lua/Cairo |
| `theme/metrics.py` | Kolektor sistem dan cuaca |
| `theme/start.sh` | Peluncur dan deteksi lebar monitor utama |
| `generate-wallpaper.py` | Generator wallpaper topografi |
| `install.py` / `restore.py` | Pemasangan, pencadangan, dan pemulihan |
| `build-package.py` / `dist/` | Pembuatan dan hasil paket portabel |

Paket tidak menyertakan kredensial, log sesi, atau cadangan konfigurasi pribadi.
