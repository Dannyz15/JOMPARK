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

## How to Run the Project in VSCode

### 1. Install Required Software

Make sure all the following software is installed before getting started:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.11.1 or above)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/downloads)
- [Android Studio](https://developer.android.com/studio) (for Android Emulator) **or** a physical Android device

After installing Flutter, open a terminal and run:
```
flutter doctor
```
Make sure all items show a ✓ before proceeding.

---

### 2. Install Flutter Extension in VSCode

1. Open VSCode
2. Press `Ctrl + Shift + X` to open Extensions
3. Search and install:
   - **Flutter** (by Dart Code)
   - **Dart** (by Dart Code)

---

### 3. Clone the Project

Open the terminal in VSCode (`Ctrl + `` `) and run:

```bash
git clone https://github.com/Dannyz15/JOMPARK.git
cd JOMPARK
```

---

### 4. Install Dependencies

In the terminal, run:

```bash
flutter pub get
```

---

### 5. Connect a Device or Open an Emulator

**Option A — Physical Android device:**
1. Enable **Developer Options** on your phone
2. Turn on **USB Debugging**
3. Connect your phone to the computer via USB cable
4. Allow the debug permission when prompted

**Option B — Android Emulator:**
1. Open Android Studio
2. Go to **Device Manager**
3. Create or select an emulator, then click **Play**

Verify your device is detected by running:
```bash
flutter devices
```

---

### 6. Run the Application

In VSCode, press `F5` **or** run in the terminal:

```bash
flutter run
```

The JomPark app will start running on the selected device or emulator.

---

### Additional Notes

- To switch devices while `flutter run` is running, press `d` in the terminal
- For hot reload (update UI without restarting), press `r`
- For hot restart (full restart), press `R`
- To stop the application, press `q`

---

## Technologies

- **Flutter** — Cross-platform mobile application framework
- **Dart** — Programming language
- **ValueNotifier** — Reactive state management
- **CustomPainter** — Custom 2D map rendering

---

## Requirements

- Flutter SDK ^3.11.1
- Dart SDK ^3.11.1
- Android / iOS device or emulator
