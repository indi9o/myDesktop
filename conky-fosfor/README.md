# Conky Fosfor

[Kembali ke galeri tema](../README.md#galeri-tema)

**Terminal minimal · fosfor hijau · osiloskop.** Fosfor meniru layar CRT monokrom: semua informasi ditampilkan sebagai sesi terminal di panel kiri, sedangkan sisi kanan wallpaper memuat graticule osiloskop dengan jejak Lissajous 3:2. Huruf dan angka memiliki pendar halus serta garis pindai (scanline) yang sejalan dengan wallpaper. Tidak ada panel latar atau ilustrasi raster, jadi tampilannya ringan dan tenang.

Panel kiri berurutan seperti keluaran perintah:

- `date`: jam piksel besar dengan kursor garis bawah, hari dan tanggal berbahasa Indonesia, serta cuaca Malang.
- `sysstat`: meter tersegmen untuk CPU, RAM, dan SSD. Meter berubah kuning pada 75% dan merah pada 90%.
- Daftar kunci–nilai: memori tersedia, zram dan jejak RAM fisiknya, swap SSD, ruang SSD kosong, suhu CPU, dan lama menyala.
- `tail -f cpu.log`: jejak beban CPU tiga menit terakhir.
- Prompt kosong dengan kursor blok sebagai penutup.

Palet utama adalah hijau fosfor P31 `7DF0A0`, hijau terang `C9FFD9`, dan hijau redup `4F8F66`. Kuning `F2B84B` serta merah `FF6E5E` hanya muncul sebagai peringatan.

## Kebutuhan

Ditujukan untuk Ubuntu/Debian dengan desktop GNOME, paling sesuai untuk layar 16:9. Transparansi dan penempatan dapat berbeda menurut compositor; pada Wayland, Conky memakai dukungan X11/XWayland yang tersedia. Dock, ikon, dan panel GNOME mengikuti konfigurasi desktop Anda.

```bash
sudo apt update
sudo apt install conky-all python3 fonts-dejavu-core x11-xserver-utils
```

Jalankan installer dari sesi desktop pengguna biasa, **tanpa `sudo`**.

## Pemasangan

Dari root repositori:

```bash
cd conky-fosfor
python3 install.py
```

Jika memakai paket portabel, ekstrak lalu jalankan `python3 install.py` dari folder `Conky-Fosfor`.

Installer mencadangkan konfigurasi Conky dan wallpaper sebelumnya di `~/.config/conky/Fosfor-backups/`, menyalin tema ke `~/.config/conky/Fosfor`, mengatur wallpaper dan autostart, lalu mengganti Conky yang sedang berjalan. Lebar layout mengikuti monitor utama melalui `xrandr`.

## Menjalankan ulang

```bash
~/.config/conky/Fosfor/start.sh
```

## Memulihkan tampilan sebelumnya

```bash
python3 ~/.config/conky/Fosfor/restore.py
```

## Data dan penyesuaian

- Metrik sistem dibaca setiap tiga detik; cuaca diperbarui setiap 15 menit.
- RAM terpakai dihitung berdasarkan `MemAvailable`.
- Alokasi swap zram dan jejak RAM fisiknya ditampilkan terpisah. Jika zram tidak tersedia, nilainya ditampilkan nol.
- Persentase SSD mengikuti perhitungan `df`, berdasarkan ruang yang tersedia untuk pengguna.
- `cpu.log` menyimpan 60 sampel (tiga menit) di memori kolektor. Setelah tema dijalankan ulang, riwayatnya mulai dari kosong.
- Cuaca [Open-Meteo](https://open-meteo.com/) memakai koordinat Malang. Data yang tidak tersedia atau lebih tua dari dua jam ditandai `CUACA TIDAK TERSEDIA`.
- Untuk mengganti kota, ubah koordinat di `theme/metrics.py` dan label `MALANG` di `theme/fosfor.lua` sebelum memasang.
- Warna, ambang peringatan, dan tata letak diatur di `theme/fosfor.lua`.
- Pembacaan suhu bergantung pada sensor kernel.

## Wallpaper

Wallpaper digambar secara prosedural dengan Cairo, tanpa aset unduhan. Untuk membuat ulang `theme/fosfor-wallpaper.png` setelah mengubah generator, jalankan:

```bash
python3 generate-wallpaper.py
```

Generator hanya diperlukan saat pengembangan, membutuhkan `python3-cairo`, dan tidak disertakan dalam paket portabel.

## Paket portabel dan pengembangan

Paket siap salin: [Conky-Fosfor-portable.tar.gz](dist/Conky-Fosfor-portable.tar.gz). Petunjuk ringkas ada di [PETUNJUK.txt](PETUNJUK.txt).

Setelah mengedit source, buat ulang paket dari folder tema:

```bash
python3 build-package.py
```

Mengedit source proyek tidak langsung mengubah salinan terpasang; jalankan kembali `python3 install.py` untuk menerapkannya.

## Struktur

| Lokasi | Kegunaan |
|---|---|
| `theme/Fosfor.conf` | Konfigurasi Conky |
| `theme/fosfor.lua` | Renderer terminal, meter, jejak CPU, pendar, dan scanline |
| `theme/metrics.py` | Kolektor sistem, riwayat CPU, dan cuaca |
| `theme/start.sh` | Peluncur dan deteksi lebar monitor utama |
| `theme/fosfor-wallpaper.png` | Wallpaper osiloskop |
| `generate-wallpaper.py` | Generator wallpaper |
| `install.py` / `restore.py` | Pemasangan, pencadangan, dan pemulihan |
| `build-package.py` / `dist/` | Pembuatan dan hasil paket portabel |

Paket tidak menyertakan kredensial, log sesi, atau cadangan konfigurasi pribadi.
