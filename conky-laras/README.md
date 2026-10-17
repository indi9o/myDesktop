# Conky Laras

[Kembali ke galeri tema](../README.md#galeri-tema)

**Persawahan Nusantara · senja · jam serif.** Laras memadukan ilustrasi terasering saat senja dengan warna hijau tua, putih gading, dan emas hangat. Latar merupakan interpretasi artistik suasana pedesaan Jawa dan Bali, bukan foto atau dokumentasi lokasi tertentu.

## Komposisi ringkas

Satu kelompok transparan di kiri atas menyisakan persawahan sebagai pusat perhatian. Pada layar 1920×1080, isi widget memakai area sekitar **300×350 px**, dengan margin awal 64 px dari kiri dan atas. Tidak ada widget di kanan atau di bawah layar.

- Jam serif **56 px** berada di dalam dial tipis berdiameter sekitar 190 px.
- Ikon matahari emas dan bulan sabit menjadi aksen kecil pada lintasan; ikon aktif lebih terang.
- Tanggal memakai **13 px**, cuaca Malang **13–15 px**, serta label CPU/RAM/SSD **12 px** dan persentase **16 px**.
- CPU, RAM, dan SSD disajikan dalam satu baris ringkas. Warna angka bergeser ke amber mulai 75% dan merah bata mulai 90%.
- Grafik CPU, meter bulir padi, detail zram/swap, uptime, dan teks dekoratif tidak ditampilkan pada komposisi utama.

Penskalaan mengikuti lebar dan tinggi monitor utama, dengan acuan 1920×1080. Jendela Conky sendiri dibatasi sekitar 430×430 px pada ukuran acuan, alih-alih memenuhi layar. Wallpaper, palet, dan pembaruan tiga detik tetap dipertahankan.

## Lintasan matahari–bulan

Progres siang memakai waktu terbit–terbenam Malang; progres malam memakai terbenam hingga terbit berikutnya. Waktu tersebut dibaca dari data harian [Open-Meteo](https://open-meteo.com/en/docs). Angka jam mengikuti zona waktu komputer, sedangkan siklus Malang memakai WIB. Ikon Bulan adalah ilustrasi progres malam, bukan perhitungan posisi, waktu terbit, atau fase Bulan astronomis.

Data disimpan bersama cache cuaca. Jika cache tidak mencakup waktu sekarang, dial memakai perkiraan siklus 06.00–18.00 WIB dan menampilkan **SIKLUS PERKIRAAN**. Label panjang serta waktu terbit/terbenam disembunyikan dari dial agar tetap ringkas.

Metrik dan gambar Conky diperbarui setiap tiga detik; cuaca setiap 15 menit. Tidak ada loop animasi cepat, visualizer audio, atau pengambilan suara. Membuat atau mengedit source tidak mengubah desktop aktif; perubahan diterapkan setelah installer dijalankan.

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

Installer mencadangkan wallpaper, autostart, dan konfigurasi Laras sebelumnya di `~/.config/conky/Laras-backups/`. Tema disalin ke `~/.config/conky/Laras`, wallpaper dan autostart diatur, lalu Conky yang sedang berjalan diganti. Ukuran layout mengikuti lebar dan tinggi monitor utama melalui `xrandr`, dengan acuan 1920×1080.

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
- Kolektor masih menyediakan detail zram, swap, suhu CPU, uptime, dan riwayat CPU di `~/.cache/conky-laras/metrics.txt`. Komposisi ringkas tidak menggambarkan data tambahan ini.
- Cuaca memakai koordinat Malang melalui [Open-Meteo](https://open-meteo.com/). Data tidak tersedia atau lebih tua dari dua jam ditandai `CUACA TIDAK TERSEDIA`.
- Untuk mengganti kota, ubah koordinat dan zona waktu API pada `theme/metrics.py`, `ZONE` pada `theme/daycycle.py`, serta label `MALANG` pada `theme/laras.lua`.
- Jam dan tanggal mengikuti zona waktu lokal komputer.
- Warna, ukuran, margin, dan susunan widget diatur pada `theme/laras.lua`. Batas jendela diatur pada `theme/Laras.conf`.
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

Untuk memeriksa transisi siang–malam, batas terbit/terbenam, lewat tengah malam, dan cache tidak tersedia:

```bash
python3 -m unittest discover -s tests -v
```

Tes tersedia dalam source repositori. Builder memeriksa sintaks Python dan shell sebelum membuat arsip. Perubahan visual juga perlu diperiksa melalui render Conky pada display virtual dengan HOME sementara; jangan menjalankan installer hanya untuk membuat pratinjau.

## Struktur

| Lokasi | Kegunaan |
|---|---|
| `theme/Laras.conf` | Konfigurasi Conky |
| `theme/laras.lua` | Dial ringkas, jam, tanggal, cuaca, dan CPU/RAM/SSD |
| `theme/metrics.py` | Kolektor sistem, cuaca, dan cache terbit–terbenam |
| `theme/daycycle.py` | Perhitungan progres siang–malam dan perkiraan offline |
| `theme/start.sh` | Peluncur, penguncian, dan deteksi ukuran monitor |
| `theme/laras-wallpaper.png` | Ilustrasi terasering senja |
| `theme/wallpaper-prompt.txt` | Prompt ImageGen |
| `install.py` / `restore.py` | Pemasangan, cadangan, dan pemulihan |
| `build-package.py` / `dist/` | Pembuat dan hasil paket portabel |

Paket tidak menyertakan kredensial, log sesi, atau cadangan pribadi.
