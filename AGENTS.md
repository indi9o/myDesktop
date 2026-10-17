# Panduan agen untuk myDesktop

## Ruang lingkup

Repositori ini berisi tema desktop Linux berbasis Conky, Lua/Cairo, dan Python.
Target utama adalah Ubuntu/Debian dengan GNOME dan monitor 16:9. Pada Wayland,
tema Conky saat ini membutuhkan XWayland. Gunakan bahasa Indonesia untuk
dokumentasi dan komunikasi, kecuali pengguna meminta bahasa lain.

Baca `README.md`, `CONTEXT.md`, dan README tema yang akan diubah sebelum bekerja.
Periksa `git status` dan pertahankan perubahan pengguna yang tidak terkait.

## Struktur proyek

- `conky-orbit/`: tema astronaut dengan jam piksel.
- `conky-horizon/`: tema lanskap bulan.
- `conky-atlas/`: tema topografi; Atlas Live adalah mode dari tema yang sama.
- `conky-nusantara/`: tema gunung berapi dengan nuansa Indonesia.
- `conky-laras/`: persawahan senja dengan satu kelompok ringkas di kiri atas: dial
  matahari–bulan, jam, cuaca, dan CPU/RAM/SSD; tanpa widget bawah atau grafik CPU.
- `conky-garuda-orbit/`: astronaut Indonesia, wallpaper Lapang tanpa emblem,
  jam piksel, dan visualizer audio.
- `conky-*/theme/`: source konfigurasi, Lua, kolektor metrik, peluncur, dan aset.
- `conky-*/install.py` dan `restore.py`: pemasangan serta pemulihan desktop.
- `conky-*/build-package.py` dan `dist/`: pembuat serta hasil paket portabel.
- `docs/images/`: pratinjau penuh dan animasi; `thumbnails/` berisi thumbnail JPG.
- `CONTEXT.md`: glosarium istilah proyek, bukan spesifikasi implementasi.

## Keputusan tampilan yang dipertahankan

- README utama hanya berisi pengantar, galeri dua kolom, dan navigasi.
  Panduan pemasangan, penjelasan fitur, dan penyesuaian berada di README
  masing-masing folder tema.
- Urutan galeri: Nusantara, Garuda Orbit, Orbit, Atlas Live, Atlas, Horizon, Laras.
  Ubah urutan hanya bila diminta pengguna.
- Gunakan thumbnail statis 960×540 yang ditautkan ke gambar penuh atau GIF.
  Hindari memuat animasi besar langsung sebagai thumbnail galeri.
- Laras memakai satu kelompok ringkas di kiri atas (sekitar 300×440 px pada
  layar 1920×1080), jam 56 px, dan teks pendukung 12–16 px. Pertahankan dial
  matahari–bulan sebagai aksen; zram/swap dan uptime berada pada tiga baris kecil
  di bawah metrik inti. Grafik CPU dan widget di bawah layar tidak ditampilkan.
- Garuda Orbit memakai palet merah bata `E1785F`, putih gading `F5E8C9`,
  emas `D8B477`, hijau giok `A6C8AF`, dan warna redup `A7B8AF`.
- Panel kiri Garuda Orbit mengikuti Orbit: jam besar, singkatan hari Indonesia
  vertikal, tanggal/bulan/suhu di sampingnya, lalu cuaca dan metrik di bawah.
  CPU, RAM, SSD, serta uptime berjajar di atas tanpa background panel.
- Wallpaper Garuda Orbit bawaan adalah
  `theme/garuda-orbit-lapang-v3-wallpaper.png`: astronot di kanan setinggi sekitar
  45–50% layar, tanpa emblem Majapahit, dengan ruang angkasa tenang yang dominan.
  Varian lama tetap tersedia
  sebagai alternatif. Pertahankan ruang gelap di kiri untuk widget.

## Source dan desktop terpasang

Source proyek berbeda dari salinan di `~/.config/conky/`. Mengedit source tidak
otomatis memperbarui desktop aktif. Jangan hanya memperbaiki salinan terpasang;
pastikan perubahan yang dimaksud tercatat dalam source proyek.

Installer mengganti wallpaper, autostart, dan Conky yang sedang berjalan.
Jangan menjalankannya hanya untuk memeriksa sintaks atau membuat pratinjau.
Jika permintaan pengguna mencakup penerapan ke desktop, gunakan alur pemasangan
yang sudah ada dan pertahankan cadangannya. Tidak perlu meminta ulang otorisasi
yang sudah diberikan untuk perubahan tersebut.

Jangan menghentikan aplikasi atau proses lain untuk pengujian. Isolasi pengujian
Conky dengan HOME sementara dan display Xvfb terpisah. Jangan mengubah perangkat
audio default pengguna untuk membuat nada uji; gunakan sink audio virtual khusus
dan bersihkan proses serta sink pengujian setelah selesai.

## Implementasi

- Pertahankan pemisahan kolektor Python dan penggambaran Lua/Cairo.
- Untuk backend Cairo X11 yang dipakai saat ini, muat `cairo` dan `cairo_xlib`.
  Bebaskan context serta surface setelah menggambar.
- Layout memakai acuan 1920×1080. Pertahankan penskalaan dan keterbacaan; jangan
  menganggap ukuran dock dan panel GNOME selalu sama di setiap komputer.
- Pertahankan pembaruan metrik tiga detik dan pembaruan cuaca 15 menit kecuali
  perubahan frekuensi memang diperlukan oleh fitur yang diminta.
- RAM memakai `MemAvailable`; bedakan alokasi swap zram dari RAM fisik zram.
  Tampilkan keadaan data tidak tersedia secara jujur.
- Jangan menanam path komputer tertentu, kredensial, atau data pribadi ke source,
  paket, pratinjau, maupun prompt aset.
- Ketika menambah dependensi, perbarui pemeriksaan installer dan panduan tema.

## Visualizer Garuda Orbit

- Analisis suara keluaran utama komputer, bukan mikrofon atau status pemutar.
  Ikuti perubahan perangkat keluaran default. Audio yang diarahkan ke perangkat
  lain secara bersamaan berada di luar cakupan monitor default.
- Pertahankan 64 batang emas–merah bata, background transparan, target 20 FPS,
  dan sembunyikan setelah sekitar tiga detik tanpa suara.
- Widget utama tetap diperbarui tiga detik; animasi memakai Conky kecil terpisah.
- Posisi awal berada di bawah, tengah ke kanan, di atas dock. Pengguna dapat
  menyeret bingkai melalui `visualizer.py --configure`, lalu menyimpan posisi.
  Tampilan normal terkunci.
- Preferensi posisi disimpan di `~/.config/garuda-orbit/visualizer-position.json`;
  jangan menimpanya saat memasang ulang tema.
- PCM diproses di memori. Berkas runtime hanya menyimpan tinggi batang,
  bukan rekaman suara. Proses visualizer dan capture harus berhenti ketika
  Conky utama ditutup atau tema diganti.

## Wallpaper dan pratinjau

Gunakan alat generasi gambar untuk aset raster baru atau edit artistik. Simpan
hasil terpilih dan prompt di folder tema. Buat nama varian baru bila diminta
membuat wallpaper baru; pertahankan aset sebelumnya. Saat mengganti bawaan,
sesuaikan installer, README tema, pratinjau, dan paket portabel.

Render dan inspeksi perubahan visual sebelum melaporkan selesai. Gunakan Xvfb
pada display kosong dengan resolusi 1920×1080 dan DPI 96. Penyesuaian background
untuk render tanpa compositor hanya boleh ada di salinan pengujian, bukan source
tema yang digunakan di desktop. Tandai animasi yang memakai spektrum contoh
sebagai demonstrasi; jangan mengklaimnya sebagai rekaman audio pengguna.

Perbarui PNG, GIF bila relevan, dan thumbnail tema yang berubah. Periksa bahwa
gambar, keterangan, serta tautan galeri sesuai dengan hasil terkini.

## Verifikasi dan distribusi

Untuk setiap tema yang diubah, buat ulang paket melalui pembuatnya, misalnya:

```bash
python3 conky-garuda-orbit/build-package.py
```

Jangan mengedit arsip `.tar.gz` secara manual. Periksa isi paket agar source,
aset, dan panduan yang diperlukan tersedia, tanpa cache, log, atau cadangan
pribadi. Jangan menganggap semua builder menyertakan berkas yang sama.

Untuk perubahan visualizer atau pemrosesan audio, jalankan:

```bash
OPENBLAS_NUM_THREADS=1 python3 -m unittest discover -s conky-garuda-orbit/tests -v
```

Jika mengubah capture, lifecycle, atau editor posisi, lengkapi dengan uji
integrasi audio virtual, senyap, pergantian sumber, penghentian proses, atau
seret/simpan sesuai bagian yang berubah. Ukur sumber daya bila mengubah loop
animasi atau pemrosesan audio; bedakan pengukuran kolektor dari total tema.

Untuk perubahan dokumentasi saja, cukup periksa tautan, konsistensi isi, dan
`git diff --check`. Hindari menambah tes untuk perubahan kosmetik sederhana.

## Git dan pelaporan

Tinjau diff sebelum commit. Ikuti otorisasi pengguna yang berlaku untuk commit
dan push; jangan sertakan perubahan lain, mengubah remote, atau melakukan
force-push. Pastikan push berhasil sebelum menyatakan perubahan sudah di GitHub.

Laporan akhir menyebut perubahan utama, verifikasi yang relevan, apakah desktop
aktif sudah diterapkan, dan commit bila dibuat. Untuk aset gambar, sertakan
tautan ke berkas hasil dan prompt. Sebut keterbatasan yang benar-benar ditemukan.
