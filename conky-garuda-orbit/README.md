# Conky Garuda Orbit

[Kembali ke galeri tema](../README.md#galeri-tema)

**Indonesia · retro · astronot · orbit.** Garuda Orbit memakai wallpaper **Lapang v3**: astronot Indonesia dan ubur-ubur bercahaya menjadi fokus di sisi kanan. Tinggi astronot sekitar 45–50% layar, lebih besar daripada Lapang v2; ubur-ubur ikut diperbesar secara proporsional. Sekitar 65–70% komposisi berupa ruang angkasa tenang; galaksi redup, bintang jarang, dan asteroid minimal memberi kesan layar lebih luas. Warna biru gelap–emas, bendera merah-putih, serta detail batik dipertahankan. Varian ini tidak memakai emblem Majapahit. Layout dan warna Conky tetap sama.

[Wallpaper Lapang v3](theme/garuda-orbit-lapang-v3-wallpaper.png) menjadi latar bawaan. [Lapang v2](theme/garuda-orbit-lapang-v2-wallpaper.png) tetap tersedia. [Lapang awal](theme/garuda-orbit-lapang-wallpaper.png) tetap tersedia. Varian sebelumnya tetap tersedia sebagai alternatif: [Majapahit Nebula](theme/garuda-orbit-majapahit-wallpaper.png), [Nebula tanpa emblem](theme/garuda-orbit-nebula-wallpaper.png), dan [poster retro](theme/garuda-orbit-wallpaper.png). Wallpaper adalah ilustrasi artistik, bukan foto misi antariksa.

Panel kiri memakai jam piksel besar di atas; singkatan hari Indonesia disusun vertikal di samping tanggal, bulan, dan suhu. Cuaca Malang berada di bawahnya, diikuti informasi memori dan penyimpanan yang dipisahkan garis tipis. CPU, RAM, SSD, dan lama menyala (uptime) berjajar di atas tanpa latar panel. Panel kiri juga memuat RAM tersedia, zram, swap SSD, ruang disk kosong, dan suhu CPU. Persentase RAM dan SSD menunjukkan ruang terpakai. Palet merah bata, putih gading, emas, dan hijau giok dipertahankan pada teks dan angka; angka jam digambar melalui Cairo sehingga tidak memerlukan font piksel tambahan.

Wallpaper tetap statis; visualizer audio bergerak pada 20 FPS saat ada suara, sementara metrik diperbarui setiap tiga detik. Desktop aktif baru diganti setelah installer dijalankan.

## Kebutuhan

Ubuntu/Debian dengan desktop GNOME, paling sesuai untuk monitor 16:9. Transparansi dan penempatan dapat berbeda menurut compositor; pada Wayland diperlukan dukungan X11/XWayland untuk Conky. Dock, ikon, dan panel GNOME mengikuti konfigurasi desktop Anda.

```bash
sudo apt update
sudo apt install conky-all python3 python3-numpy python3-tk pulseaudio-utils fonts-dejavu-core x11-xserver-utils
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

## Visualizer audio

[Lihat pratinjau animasi](../docs/images/conky-garuda-orbit-audio-preview.gif). Gerak pada pratinjau memakai contoh spektrum untuk memperlihatkan penempatan; tampilan aktif mengikuti audio yang sesungguhnya.

Spektrum 64 batang mengikuti suara keluaran utama komputer: musik, video browser, dan notifikasi. Warnanya bergradasi emas–merah bata, tanpa background atau label frekuensi. Visualizer muncul saat ada suara dan menghilang setelah sekitar tiga detik senyap; ini didasarkan pada suara, bukan status play/pause pemutar.

Sumber audio mengikuti perangkat keluaran default dan diperiksa ulang setiap detik. Pergantian speaker/headset dapat memerlukan sekitar satu–dua detik. Aplikasi yang sengaja diarahkan ke perangkat lain secara bersamaan tidak tercakup. Mikrofon tidak dipakai. PCM hanya diproses di memori; berkas sementara menyimpan tinggi batang, bukan rekaman audio.

Posisi awal ada di bawah, dari tengah ke kanan, di atas dock pada layar 1920×1080. Tinggi dock berbeda-beda; geser bila diperlukan.

### Atur posisi

Cari **Garuda Orbit — Atur visualizer** di menu aplikasi, atau jalankan:

```bash
python3 ~/.config/conky/GarudaOrbit/visualizer.py --configure
```

1. Seret area batang pada bingkai pengaturan ke posisi yang diinginkan.
2. Klik **Simpan posisi**. Visualizer aktif mengikuti posisi baru dalam sekitar satu detik.
3. **Batal** atau tombol Escape menutup tanpa menyimpan; **Posisi awal** memulihkan penempatan bawaan.

Bingkai menampilkan contoh batang meskipun tidak ada audio. Saat pengaturan ditutup, visualizer kembali menjadi elemen desktop yang terkunci dan hanya muncul saat bersuara. Posisi disimpan di `~/.config/garuda-orbit/visualizer-position.json`, terpisah dari berkas tema agar tetap bertahan setelah pemasangan ulang.

Analisis audio memakai NumPy dan monitor keluaran [`parec`](https://manpages.debian.org/testing/pulseaudio-utils/parec.1.en.html). Visualizer berjalan sebagai jendela Conky kecil terpisah, sehingga widget utama tetap diperbarui setiap tiga detik. Proses audio dan jendela visualizer berhenti saat Conky utama Garuda Orbit ditutup atau diganti tema. Jika sumber audio belum tersedia, visualizer tetap tersembunyi dan mencoba kembali otomatis.

Log masalah tersedia di `~/.cache/conky-garuda-orbit/visualizer.log`. Jika audio tidak memunculkan batang, periksa perangkat default dengan `pactl get-default-sink` dan jalankan ulang tema. Fitur ini memerlukan server PulseAudio atau kompatibilitas PulseAudio dari PipeWire.

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
- Jam dan tanggal mengikuti waktu lokal sistem; singkatan hari memakai tiga huruf bahasa Indonesia (misalnya `SAB` untuk Sabtu).
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
| `theme/visualizer.py` | Analisis spektrum audio, pengelolaan proses, dan editor posisi |
| `theme/Visualizer.conf` / `theme/visualizer.lua` | Batang spektrum transparan pada 20 FPS |
| `theme/metrics.py` | Kolektor metrik dan cuaca |
| `theme/start.sh` | Peluncur dan deteksi lebar monitor |
| `theme/garuda-orbit-lapang-v3-wallpaper.png` | Wallpaper bawaan: tinggi astronot sekitar 45–50% layar, tanpa emblem |
| `theme/garuda-orbit-lapang-v2-wallpaper.png` | Alternatif Lapang v2 |
| `theme/garuda-orbit-lapang-wallpaper.png` | Alternatif Lapang awal |
| `theme/garuda-orbit-majapahit-wallpaper.png` | Alternatif Majapahit Nebula |
| `theme/garuda-orbit-nebula-wallpaper.png` | Alternatif Nebula tanpa emblem |
| `theme/garuda-orbit-wallpaper.png` | Alternatif poster astronot retro dan orbit Indonesia |
| `install.py` / `restore.py` | Pemasangan, cadangan, dan pemulihan |
| `build-package.py` / `dist/` | Pembuatan dan hasil paket portabel |

## Verifikasi pengembangan

```bash
python3 -m unittest discover -s tests -v
```

Tes memeriksa pemetaan nada ke pita frekuensi, kembali aktif setelah senyap, batas nilai batang, kegagalan sumber audio, serta penyimpanan posisi. Folder tes tersedia dalam source repositori.

Wallpaper dibuat dengan ImageGen; prompt Lapang v3 tersimpan di [lapang-v3-wallpaper-prompt.txt](theme/lapang-v3-wallpaper-prompt.txt), prompt Lapang v2 di [lapang-v2-wallpaper-prompt.txt](theme/lapang-v2-wallpaper-prompt.txt), prompt Lapang awal di [lapang-wallpaper-prompt.txt](theme/lapang-wallpaper-prompt.txt), prompt varian Majapahit di [majapahit-wallpaper-prompt.txt](theme/majapahit-wallpaper-prompt.txt), prompt Nebula di [nebula-wallpaper-prompt.txt](theme/nebula-wallpaper-prompt.txt) dan prompt poster sebelumnya di [wallpaper-prompt.txt](theme/wallpaper-prompt.txt). Paket tidak menyertakan kredensial, log sesi, atau cadangan pribadi.
