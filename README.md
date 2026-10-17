# myDesktop

Konfigurasi dan tema desktop Linux pribadi.

## Galeri tema

Pilih tampilan dari galeri berikut. Klik gambar untuk membuka pratinjau penuh; gambar Atlas Live membuka animasinya.

<table>
  <tr>
    <td width="50%" valign="top">
      <strong>Atlas Live</strong><br>
      <sub>Kontur bergerak · pemindai tembaga · panel kanan</sub><br><br>
      <a href="docs/images/conky-atlas-live-preview.gif"><img src="docs/images/thumbnails/conky-atlas-live-preview.jpg" width="100%" alt="Atlas Live: kontur topografi dengan jam serif dan statistik di kanan"></a><br><br>
      <a href="#atlas-live">Pemasangan</a> · <a href="docs/images/conky-atlas-live-preview.gif">Lihat animasi</a>
    </td>
    <td width="50%" valign="top">
      <strong>Atlas</strong><br>
      <sub>Topografi statis · aksen tembaga · panel kanan</sub><br><br>
      <a href="docs/images/conky-atlas-preview.png"><img src="docs/images/thumbnails/conky-atlas-preview.jpg" width="100%" alt="Atlas statis: jam serif, kontur topografi, dan panel statistik"></a><br><br>
      <a href="#atlas-statis">Pemasangan</a> · <a href="conky-atlas/">Source</a>
    </td>
  </tr>
  <tr>
    <td width="50%" valign="top">
      <strong>Horizon</strong><br>
      <sub>Lanskap bulan · jam minimalis · metrik horizontal</sub><br><br>
      <a href="docs/images/conky-horizon-preview.png"><img src="docs/images/thumbnails/conky-horizon-preview.jpg" width="100%" alt="Horizon: jam minimalis, lanskap bulan, dan metrik di bagian bawah"></a><br><br>
      <a href="#horizon">Pemasangan</a> · <a href="conky-horizon/">Source</a>
    </td>
    <td width="50%" valign="top">
      <strong>Orbit</strong><br>
      <sub>Astronaut · jam piksel retro · panel kiri</sub><br><br>
      <a href="docs/images/conky-orbit-preview.png"><img src="docs/images/thumbnails/conky-orbit-preview.jpg" width="100%" alt="Orbit: wallpaper astronaut, jam piksel, dan panel statistik di kiri"></a><br><br>
      <a href="#orbit">Pemasangan</a> · <a href="conky-orbit/">Source</a>
    </td>
  </tr>
</table>

*Semua pratinjau memakai rasio 16:9. Nilai sistem pada gambar adalah cuplikan saat render; dock dan panel mengikuti desktop masing-masing. Atlas Live adalah mode animasi dari tema Atlas.*

## Conky Atlas

Tema dengan wallpaper kontur topografi generatif, palet charcoal–sage–tembaga, jam serif di kiri bawah, dan panel statistik vertikal di kanan. Panel menampilkan CPU, RAM tersedia, ruang disk, zram, swap SSD, dan riwayat singkat beban CPU.

<a id="atlas-live"></a>

### Atlas Live — animasi Lua/Cairo

Kontur bergerak perlahan dengan pemindai tembaga dan titik survei; jam dan panel statistik tetap diam. Animasi berjalan dengan target 8 fps, sementara pembacaan metrik dan riwayat CPU tetap setiap tiga detik. Artwork didekode sekali dan digunakan ulang dari memori; tidak memakai video player atau browser tambahan.

*GIF mengambil 2 frame per detik untuk ukuran file yang lebih kecil. Gerakan nyata ditargetkan 8 fps; Conky memakai interval lebih lambat saat mendeteksi penggunaan baterai. Pemakaian CPU dan memori bergantung perangkat dan compositor.*

Pada pengukuran singkat 12 detik di desktop pengembangan, proses Conky memakai sekitar 48,8 MiB RAM dan 2,42% dari satu inti CPU. Angka tersebut tidak mencakup compositor/GPU dan bukan jaminan untuk perangkat lain. Lihat [catatan pengukuran](conky-atlas/LIVE-BENCHMARK.txt).

Untuk memasang dan mengaktifkan Atlas Live, termasuk saat login:

```bash
cd conky-atlas
python3 install.py --live
```

Untuk beralih ke mode statis pada sesi berjalan:

```bash
~/.config/conky/Atlas/start.sh --static
```

Untuk kembali ke animasi, ganti `--static` dengan `--live`. Cadangan wallpaper dan konfigurasi sebelum pemasangan dapat dipulihkan dengan perintah `restore.py` di bawah.

<a id="atlas-statis"></a>

### Atlas statis

Kontur Atlas bersifat ilustratif, bukan peta medan nyata.

Dengan dependensi yang sama seperti Orbit, jalankan tanpa `sudo` dari sesi desktop:

```bash
cd conky-atlas
python3 install.py
```

Untuk memulihkan wallpaper dan Conky sebelumnya:

```bash
python3 ~/.config/conky/Atlas/restore.py
```

Paket portabel: [`Conky-Atlas-portable.tar.gz`](conky-atlas/dist/Conky-Atlas-portable.tar.gz). Lihat [petunjuk Atlas](conky-atlas/PETUNJUK.txt).

Wallpaper dibuat dari kurva vektor deterministik; [generator](conky-atlas/generate-wallpaper.py) dan [source SVG](conky-atlas/theme/topography-wallpaper.svg) disertakan. Pembuatan ulang wallpaper memerlukan `python3-cairo`, tetapi pemasangan tema cukup memakai berkas PNG yang sudah tersedia.

<a id="horizon"></a>

## Conky Horizon

Alternatif dengan wallpaper lunar, jam besar bernuansa ivory, tanggal dan cuaca yang ringkas, serta enam metrik sistem dalam satu baris. Panel bawah diberi latar gelap agar statistik tetap terbaca di atas permukaan bulan.

Pasang dependensi yang sama seperti Orbit di bawah, lalu jalankan dari sesi desktop tanpa `sudo`:

```bash
cd conky-horizon
python3 install.py
```

Installer mencadangkan wallpaper dan konfigurasi Conky sebelumnya. Untuk memulihkannya:

```bash
python3 ~/.config/conky/Horizon/restore.py
```

Paket portabel: [`Conky-Horizon-portable.tar.gz`](conky-horizon/dist/Conky-Horizon-portable.tar.gz). Lihat [petunjuk Horizon](conky-horizon/PETUNJUK.txt).

<a id="orbit"></a>

## Conky Orbit

Tema desktop dengan jam piksel, tanggal, cuaca Malang, wallpaper astronaut, serta metrik CPU, RAM, disk, uptime, swap SSD, dan zram. Widget membaca metrik sistem setiap tiga detik; cuaca diperbarui setiap 15 menit.

Ditujukan untuk Ubuntu/Debian dengan desktop GNOME. Transparansi dan penempatan dapat berbeda menurut compositor; tampilan paling sesuai untuk layar 16:9. Dock, ikon, dan panel GNOME tidak diubah.

### Pemasangan

Pasang dependensi:

```bash
sudo apt update
sudo apt install conky-all python3 fonts-dejavu-core x11-xserver-utils
```

Dari sesi desktop pengguna biasa, jalankan tanpa `sudo`:

```bash
cd conky-orbit
python3 install.py
```

Installer mencadangkan konfigurasi sebelumnya, memasang tema ke `~/.config/conky/Orbit`, mengatur wallpaper dan autostart, lalu menjalankan Conky. Lokasi cuaca bawaan adalah Malang; koordinat dapat diubah di `theme/metrics.py` dan label kota di `theme/orbit.lua`.

Untuk memulihkan tampilan sebelumnya:

```bash
python3 ~/.config/conky/Orbit/restore.py
```

### Paket portabel

Paket siap salin tersedia di [`conky-orbit/dist/Conky-Orbit-portable.tar.gz`](conky-orbit/dist/Conky-Orbit-portable.tar.gz). Untuk membuat ulang setelah mengubah source:

```bash
cd conky-orbit
python3 build-package.py
```

Lihat [petunjuk lengkap](conky-orbit/PETUNJUK.txt) dan [catatan proyek](conky-orbit/README.txt).

### Struktur

- `conky-orbit/theme/` — konfigurasi Conky, renderer Lua/Cairo, kolektor metrik Python, peluncur, dan wallpaper.
- `conky-orbit/install.py` — pemasangan dan pencadangan konfigurasi.
- `conky-orbit/restore.py` — pemulihan konfigurasi sebelum pemasangan.
- `conky-orbit/build-package.py` — pembuatan arsip distribusi.
- `conky-orbit/dist/` — paket portabel.

Wallpaper dibuat menggunakan ImageGen; prompt tersedia di `conky-orbit/theme/wallpaper-prompt.txt`. Data cuaca berasal dari [Open-Meteo](https://open-meteo.com/).
