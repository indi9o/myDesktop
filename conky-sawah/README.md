# Conky Sawah

[Kembali ke galeri tema](../README.md#galeri-tema)

**Terasering · senja · gunung api.** Sawah menampilkan senja di atas terasering. Petak-petak sawah melengkung mengikuti punggungan bukit, sebagian tergenang dan memantulkan langit jingga, sebagian berisi padi muda atau padi yang mulai menguning. Di cakrawala terlihat gunung api, deretan pepohonan, dan pohon kelapa, dengan matahari rendah di antara puncaknya. Sisi kiri wallpaper digelapkan agar widget tetap terbaca.

Panel kiri berisi:

- Jam serif besar, hari dan tanggal lengkap berbahasa Indonesia, serta cuaca Malang.
- **Lintasan matahari 24 jam**: garis cakrawala dari 00 sampai 24 dengan lengkung siang di atasnya (terbit → terbenam) dan lengkung malam di bawahnya. Bagian hari yang sudah berlalu disorot jingga; penanda waktu sekarang berupa matahari saat siang dan bulan sabit saat malam. Jam terbit dan terbenam ditulis dalam format 24 jam dan dihitung secara lokal dari koordinat, sehingga tidak bergantung pada internet.
- Meter CPU, RAM, dan SSD berupa deretan 20 bulir padi (masing-masing 5%). Bulir berwarna hijau padi, berubah jingga pada 75% dan merah bata pada 90%.
- Memori tersedia, zram dan jejak RAM fisiknya, swap SSD, ruang SSD kosong, suhu CPU, dan lama menyala.

Palet: krem `F3E6CC`, jingga senja `E9A86A`, hijau padi `9CC37A`, merah bata `D9735B`, dan abu hangat `B9A99A`.

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
cd conky-sawah
python3 install.py
```

Jika memakai paket portabel, ekstrak lalu jalankan `python3 install.py` dari folder `Conky-Sawah`.

Installer mencadangkan konfigurasi Conky dan wallpaper sebelumnya di `~/.config/conky/Sawah-backups/`, menyalin tema ke `~/.config/conky/Sawah`, mengatur wallpaper dan autostart, lalu mengganti Conky yang sedang berjalan. Lebar layout mengikuti monitor utama melalui `xrandr`.

## Menjalankan ulang

```bash
~/.config/conky/Sawah/start.sh
```

## Memulihkan tampilan sebelumnya

```bash
python3 ~/.config/conky/Sawah/restore.py
```

## Data dan penyesuaian

- Metrik sistem dibaca setiap tiga detik; cuaca diperbarui setiap 15 menit.
- RAM terpakai dihitung berdasarkan `MemAvailable`.
- Alokasi swap zram dan jejak RAM fisiknya ditampilkan terpisah. Jika zram tidak tersedia, nilainya ditampilkan nol.
- Persentase SSD mengikuti perhitungan `df`, berdasarkan ruang yang tersedia untuk pengguna.
- Cuaca [Open-Meteo](https://open-meteo.com/) memakai koordinat Malang. Data yang tidak tersedia atau lebih tua dari dua jam ditandai `Cuaca Tidak Tersedia`.
- Jam terbit dan terbenam memakai persamaan matahari (ketelitian sekitar satu menit) dengan koordinat yang sama dan zona waktu sistem.
- Untuk mengganti kota, ubah `LAT, LON` di `theme/metrics.py` dan label `Malang` di `theme/sawah.lua` sebelum memasang.
- Warna, ambang peringatan, dan tata letak diatur di `theme/sawah.lua`.
- Pembacaan suhu bergantung pada sensor kernel.

## Wallpaper

Wallpaper digambar secara prosedural, tanpa aset unduhan. Medan sawah adalah bidang kontur dua dimensi: setiap pita kontur menjadi satu teras, punggungan bukit membengkokkan teras menjadi lengkungan, dan pematang melintang membagi teras menjadi petak. Untuk membuat ulang `theme/sawah-wallpaper.png`:

```bash
python3 generate-wallpaper.py
```

Generator hanya diperlukan saat pengembangan, membutuhkan `python3-cairo` serta `python3-numpy`, dan tidak disertakan dalam paket portabel.

## Paket portabel dan pengembangan

Paket siap salin: [Conky-Sawah-portable.tar.gz](dist/Conky-Sawah-portable.tar.gz). Petunjuk ringkas ada di [PETUNJUK.txt](PETUNJUK.txt).

Setelah mengedit source, buat ulang paket dari folder tema:

```bash
python3 build-package.py
```

Mengedit source proyek tidak langsung mengubah salinan terpasang; jalankan kembali `python3 install.py` untuk menerapkannya.

## Struktur

| Lokasi | Kegunaan |
|---|---|
| `theme/Sawah.conf` | Konfigurasi Conky |
| `theme/sawah.lua` | Renderer jam, lintasan matahari, meter bulir padi, dan metrik |
| `theme/metrics.py` | Kolektor sistem, jam matahari, dan cuaca |
| `theme/start.sh` | Peluncur dan deteksi lebar monitor utama |
| `theme/sawah-wallpaper.png` | Wallpaper terasering senja |
| `generate-wallpaper.py` | Generator wallpaper |
| `install.py` / `restore.py` | Pemasangan, pencadangan, dan pemulihan |
| `build-package.py` / `dist/` | Pembuatan dan hasil paket portabel |

Paket tidak menyertakan kredensial, log sesi, atau cadangan konfigurasi pribadi.
