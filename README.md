# JomPark

JomPark ialah aplikasi mudah alih tempat letak kereta yang direka untuk memudahkan pengguna mencari, menempah, dan mengurus tempat letak kereta di sekitar kawasan Kampung Baru, Kuala Lumpur. Dibangunkan menggunakan Flutter, JomPark menawarkan pengalaman pengguna yang mudah dan pantas.

---

## Fungsi Utama

### Peta
- Papar peta 2D kawasan Kampung Baru dengan lokasi semua tempat letak kereta berdekatan
- Tunjukkan harga setiap lokasi terus pada peta
- Tekan penanda untuk lihat butiran tempat letak kereta

### Tiket
- Papar tiket aktif selepas tempahan dibuat
- Kiraan masa nyata (countdown timer) untuk tempoh parkir
- Lanjut masa parkir dengan pilihan tambahan masa yang fleksibel
- Pengesahan sebelum lanjut masa bagi mengelakkan kesilapan

### Sejarah
- Simpan rekod semua tempahan parkir lepas
- Tapis sejarah mengikut jenis tempat letak kereta (semua, dalam bangunan, luar bangunan, EV)
- Papar maklumat lengkap termasuk lokasi, slot, plat kenderaan, tempoh, dan jumlah bayaran

### Profil
- Urus senarai kenderaan berdaftar
- Tambah dan padam kenderaan dengan maklumat plat nombor, model, dan warna

---

## Tempat Letak Kereta di Kampung Baru

| Lokasi | Jarak | Harga | Jenis |
|--------|-------|-------|-------|
| Kg. Baru Sentral P | 0.2 km | RM 2.00/jam | Dalam Bangunan |
| Masjid KBaru Open Air | 0.5 km | RM 1.50/jam | Luar Bangunan |
| Chow Kit Plaza EV | 0.9 km | RM 3.00/jam | EV Charging |
| DBP Parking | 1.1 km | RM 2.50/jam | Dalam Bangunan |
| PWTC Parking | 1.4 km | RM 1.00/jam | Luar Bangunan |

---

## Teknologi

- **Flutter** — Framework pembangunan aplikasi merentas platform
- **Dart** — Bahasa pengaturcaraan
- **ValueNotifier** — Pengurusan state reaktif
- **CustomPainter** — Lukisan peta 2D tersuai

---

## Keperluan

- Flutter SDK ^3.11.1
- Dart SDK ^3.11.1
- Android / iOS device atau emulator
