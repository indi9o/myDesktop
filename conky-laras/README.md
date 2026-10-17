# Conky Laras

[Kembali ke galeri tema](../README.md#galeri-tema)

**Persawahan Nusantara · senja · jam serif.** Laras memadukan ilustrasi terasering saat senja dengan warna hijau tua, putih gading, dan emas hangat. Latar merupakan interpretasi artistik suasana pedesaan Jawa dan Bali, bukan foto atau dokumentasi lokasi tertentu.

Jam dan tanggal Indonesia berada di tengah atas, dengan cuaca Malang di bawahnya. Lima kelompok metrik di bagian bawah menampilkan CPU dan suhu, memori tersedia, penyimpanan kosong, zram, serta swap SSD. Uptime berada di kanan atas. Semua elemen digambar langsung di atas wallpaper tanpa panel latar; garis tipis di bawah tiga metrik pertama menunjukkan persentase CPU, RAM terpakai, dan disk terpakai.

Tema ini statis. Metrik diperbarui setiap tiga detik; cuaca setiap 15 menit. Tidak ada visualizer audio atau pengambilan suara. Membuat atau mengedit source tidak mengubah desktop aktif; perubahan diterapkan setelah installer dijalankan.

## Kebutuhan

Ubuntu/Debian dengan GNOME, paling sesuai untuk layar 16:9. Pada Wayland diperlukan dukungan X11/XWayland untuk Conky. Penempatan dan transparansi bergantung pada compositor; dock dan panel mengikuti pengaturan desktop pengguna.

```bash
sudo apt update
sudo apt install conky-all python3 fonts-dejavu-core x11-xserver-utils
```

## Pemasangan

Dari root repositori, jalankan sebagai pengguna desktop biasa, **tanpa sudo**:

```bash
cd conky-laras
python3 install.py
```

Paket portabel dapat diekstrak lalu dipasang dengan `python3 install.py` dari folder `Conky-Laras`.

Installer mencadangkan wallpaper, autostart, dan konfigurasi Laras sebelumnya di `~/.config/conky/Laras-backups/`. Tema disalin ke `~/.config/conky/Laras`, wallpaper dan autostart diatur, lalu Conky yang sedang berjalan diganti. Lebar layout mengikuti monitor utama melalui `xrandr`, dengan acuan 1920×1080.

## Menjalankan ulang

```bash
~/.config/conky/Laras/start.sh
```

## Memulihkan tampilan sebelumnya

```bash
python3 ~/.config/conky/Laras/restore.py
```

Pemulihan mengembalikan wallpaper dan autostart sebelumnya. Untuk tema myDesktop yang memiliki peluncur, tema sebelumnya dijalankan lewat `start.sh` agar proses pendukungnya ikut pulih. Cadangan tetap disimpan.

## Data dan penyesuaian

- RAM tersedia dibaca dari `MemAvailable`; persentase RAM terpakai dihitung dari total dikurangi nilai tersebut.
- Persentase penyimpanan mengikuti perhitungan `df` untuk filesystem `/`, berdasarkan ruang yang tersedia bagi pengguna.
- Zram menampilkan alokasi swap dan RAM fisik secara terpisah. Swap lain ditampilkan sebagai `SWAP SSD`; label ini mengasumsikan swap non-zram berada di SSD dan tidak mendeteksi jenis media fisik.
- Tidak ada zram atau swap: nilai alokasi ditampilkan nol. Sensor atau jejak RAM fisik zram yang tidak dapat dibaca ditandai `--`.
- Cuaca memakai koordinat Malang melalui [Open-Meteo](https://open-meteo.com/). Data tidak tersedia atau lebih tua dari dua jam ditandai `CUACA TIDAK TERSEDIA`.
- Untuk mengganti kota, ubah koordinat pada `theme/metrics.py` serta label `MALANG` pada `theme/laras.lua`.
- Jam dan tanggal mengikuti zona waktu lokal komputer.
- Warna, ukuran, susunan widget, dan ornamen padi diatur pada `theme/laras.lua`.
- Kolektor metrik berhenti ketika proses Conky utama Laras yang diluncurkan oleh `start.sh` berakhir.

Log tersedia di `~/.cache/conky-laras/`. Jalankan ulang installer setelah mengubah source untuk memperbarui salinan terpasang.

## Wallpaper dan pratinjau

[Wallpaper Laras](theme/laras-wallpaper.png) dibuat dengan ImageGen. Prompt tersimpan di [wallpaper-prompt.txt](theme/wallpaper-prompt.txt). Aset tidak memuat jam atau statistik; widget digambar secara terpisah melalui Lua/Cairo.

[Pratinjau penuh](../docs/images/conky-laras-preview.png) memperlihatkan nilai sistem pada saat render, bukan data yang diperbarui dalam gambar. Panel GNOME dan dock tidak disertakan dalam render terisolasi.

## Paket portabel dan pengembangan

[Paket siap salin](dist/Conky-Laras-portable.tar.gz) berisi installer, pemulih, README, petunjuk ringkas, serta seluruh berkas tema.

Buat ulang paket setelah mengubah source:

```bash
python3 build-package.py
```

Builder memeriksa sintaks Python dan shell sebelum membuat arsip. Perubahan visual juga perlu diperiksa melalui render Conky pada display virtual dengan HOME sementara; jangan menjalankan installer hanya untuk membuat pratinjau.

## Struktur

| Lokasi | Kegunaan |
|---|---|
| `theme/Laras.conf` | Konfigurasi Conky |
| `theme/laras.lua` | Jam serif, tanggal, cuaca, dan metrik |
| `theme/metrics.py` | Kolektor sistem dan cuaca |
| `theme/start.sh` | Peluncur, penguncian, dan deteksi lebar monitor |
| `theme/laras-wallpaper.png` | Ilustrasi terasering senja |
| `theme/wallpaper-prompt.txt` | Prompt ImageGen |
| `install.py` / `restore.py` | Pemasangan, cadangan, dan pemulihan |
| `build-package.py` / `dist/` | Pembuat dan hasil paket portabel |

Paket tidak menyertakan kredensial, log sesi, atau cadangan pribadi.
