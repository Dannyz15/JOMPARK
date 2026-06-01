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

## Cara Jalankan Projek di VSCode

### 1. Pasang Perisian yang Diperlukan

Pastikan semua perisian berikut telah dipasang sebelum memulakan:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.11.1 ke atas)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/downloads)
- Android Studio (untuk Android Emulator) **atau** telefon Android fizikal

Selepas pasang Flutter, buka terminal dan jalankan:
```
flutter doctor
```
Pastikan semua item menunjukkan tanda ✓ sebelum teruskan.

---

### 2. Pasang Extension Flutter dalam VSCode

1. Buka VSCode
2. Tekan `Ctrl + Shift + X` untuk buka Extensions
3. Cari dan pasang:
   - **Flutter** (oleh Dart Code)
   - **Dart** (oleh Dart Code)

---

### 3. Clone Projek

Buka terminal dalam VSCode (`Ctrl + `` `) dan jalankan:

```bash
git clone https://github.com/Dannyz15/JOMPARK.git
cd JOMPARK
```

---

### 4. Install Dependencies

Dalam terminal, jalankan:

```bash
flutter pub get
```

---

### 5. Sambungkan Peranti atau Buka Emulator

**Pilihan A — Telefon Android fizikal:**
1. Aktifkan **Developer Options** pada telefon
2. Hidupkan **USB Debugging**
3. Sambungkan telefon ke komputer menggunakan kabel USB
4. Benarkan kebenaran debug apabila diminta

**Pilihan B — Android Emulator:**
1. Buka Android Studio
2. Pergi ke **Device Manager**
3. Buat atau pilih emulator, kemudian klik **Play**

Semak peranti dikesan dengan jalankan:
```bash
flutter devices
```

---

### 6. Jalankan Aplikasi

Dalam VSCode, tekan `F5` **atau** jalankan dalam terminal:

```bash
flutter run
```

Aplikasi JomPark akan mula berjalan pada peranti atau emulator yang dipilih.

---

### Nota Tambahan

- Untuk tukar peranti semasa `flutter run` sedang berjalan, tekan `d` dalam terminal
- Untuk hot reload (kemaskini UI tanpa restart), tekan `r`
- Untuk hot restart (restart penuh), tekan `R`
- Untuk hentikan aplikasi, tekan `q`

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
