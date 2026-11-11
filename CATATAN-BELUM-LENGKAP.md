# Catatan: yang belum lengkap, belum teruji, atau tidak berfungsi

Dokumen ini jujur soal batas EFI ini. Tabel status di `README.md` hanya berisi hal terbukti; di sini semua sisanya.

## Tidak berfungsi
- **Sleep / wake.** Laptop tidak bisa bangun setelah tidur (layar hitam, harus mati paksa). Dugaan: banyak laptop Ice Lake hanya mendukung S0ix (Modern Standby) tanpa S3; periksa `_S3` di DSDT, `pmset -g log`, `pmset -g assertions`, kelengkapan UTBMap, dan patch GPRW (wake lewat USB/GPIO trackpad I2C). Belum diuji.
  Solusi sementara: matikan sleep sistem (catatan: `disablesleep 1` juga mematikan sleep saat penutup ditutup, baterai bisa terkuras).
  `sudo pmset -a sleep 0 disablesleep 1 displaysleep 10`
  Mati paksa berulang berisiko mereset BIOS (lihat `TROUBLESHOOTING.md`).
- **AirDrop, Handoff, Continuity.** Butuh kartu WiFi/Bluetooth Broadcom; tidak tersedia dengan kartu Intel + itlwm.

## Belum stabil
- **Boot otomatis ke Macintosh HD.** Pilihan default OpenCore (Ctrl+Enter) belum tersimpan di NVRAM; picker memilih Windows. `Misc > Security > AllowSetDefault` sudah `true`. Dugaan lama: NVRAM tidak bertahan karena BIOS ter-reset (baterai CMOS lemah). Dugaan ini lemah, sebab variabel UEFI disimpan di flash, bukan di CMOS. Kandidat lain: firmware InsydeH20 mengabaikan atau menimpa `BootOrder`, atau Windows Boot Manager menimpanya kembali (`LauncherOption = Full` dan `RequestBootVarRouting = true` sudah diatur di config); ada dua disk (SATA macOS, NVMe Windows). Coba juga menaruh disk macOS di prioritas pertama menu boot BIOS. Belum dibuktikan.

## Belum dikonfirmasi
- **Webcam**: terdeteksi di USB (Quanta HD User Facing), gambar di Photo Booth belum dikonfirmasi.
- **Bluetooth**: macOS melaporkan Bluetooth menyala dan scan menemukan HP, tetapi koneksi ke HP dan TWS **gagal**. "BT5.2 Mouse" berstatus Tidak Terhubung; USB `3151:3020` yang terlihat kemungkinan receiver 2,4 GHz, bukan Bluetooth. Mengaktifkan `IntelBTPatcher` 2.4.0 menyebabkan **kernel panic berulang** (backtrace: `bluetoothd` -> `IOUSBHostFamily` -> `IntelBTPatcher`), jadi jangan diaktifkan. Opsi: coba versi kext lain (dengan cadangan EFI di flashdisk) atau dongle Bluetooth USB.
- **Ukuran huruf / HiDPI**: layar 1920x1080 tanpa penskalaan terasa kecil. Mode HiDPI belum dipasang.
- **Performa render video**: akselerasi VideoToolbox (H.264/HEVC) belum diuji.

## Catatan dari pemeriksaan `config.plist` (belum dipahami / perlu dicek)
Hasil membaca cadangan `config.plist` (data pribadi sudah dibuang). Belum diputuskan atau diuji; dicatat supaya tidak hilang.
- **Status kext Bluetooth (sudah diselaraskan).** Config di laptop memakai `IntelBluetoothFirmware = true`, `BlueToolFixup = true`, `IntelBTPatcher = false`; `config.plist` di repo sekarang sama. Cadangan lama berisi ketiganya `false`.
- **Komentar kext usang (sudah dikoreksi di `EFI/OC/config.plist` repo ini).** Di cadangan asli komentar menyebut "AX210" (kartunya AX201), "PLACEHOLDER" untuk USBToolBox/UTBMap, dan "USB Ethernet" untuk RealtekRTL8111 (sebenarnya PCIe). Hanya komentar, tidak memengaruhi fungsi; salin perbaikan ke `config.plist` di laptop jika mau.
- **Peta USB (`UTBMap.kext`) sudah nyata, bukan placeholder.** Dicek di cadangan Drive: satu pengendali XHC, `port-count` 15 (batas 15 port terpenuhi), 9 port terdaftar: HS01, HS02 (konektor USB 3), HS03 (USB 2), HS04 dan SS03 (konektor tipe 9, Type-C), HS05 dan HS06 (internal, kemungkinan Bluetooth dan webcam), SS01 dan SS02 (USB 3). Komentar "PLACEHOLDER" di `config.plist` hanya usang. Kecocokan dengan port fisik sudah dicek lewat tangkapan layar ringkasan spesifikasi dari pencarian web (sumber sekunder, bukan dokumen resmi Acer): 2x USB 3.x Type-A (kiri), 1x USB 2.0 Type-A (kanan), 1x USB Type-C 3.2 Gen 1 (kiri). Ini cocok dengan peta: HS01+SS01 dan HS02+SS02 untuk Type-A USB 3, HS03 untuk USB 2, HS04+SS03 untuk Type-C. Yang belum dicek: apakah HS05 dan HS06 (internal) memang Bluetooth dan webcam.
- **Urutan kext.** `VoodooInput`, `VoodooGPIO`, dan `VoodooI2CServices` dimuat setelah kext induknya, sedangkan panduan umum menaruh dependensi lebih dulu. Saat ini berjalan, tetapi rapuh.
- **Layout audio ganda.** `DeviceProperties` mengatur `layout-id` 69 (`45000000`), sedangkan boot-args memakai `alcid=11`. Boot-arg lebih diutamakan, jadi suara tetap jalan, tetapi sebaiknya diseragamkan ke satu nilai.
- **Debug masih aktif** (`Debug > Target = 67`, `AppleDebug = true`, `-v keepsyms=1`). Boleh dimatikan setelah stabil.

## Hasil pemeriksaan arsip EFI (OC.7z)
- Repo ini referensi publik dari laptop saya sendiri. Folder `EFI/` kini berisi salinan lengkap (OpenCore, `BOOT`, 20 kext, 5 SSDT, 4 driver, `Resources`) yang sudah dibersihkan dari data pribadi. Dicek ulang: nilai serial, MLB, UUID, ROM, SSID, dan sandi asli tidak ditemukan di berkas repo mana pun.
- `config.plist` di arsip identik dengan yang di repo (selain data pribadi dan 5 komentar). Semua kext, SSDT, dan driver yang terdaftar ada di disk, dan sebaliknya.
- Nomor versi kext cocok dengan komentar di config. Tidak ada berkas LICENSE di dalam kext mana pun, jadi lisensi harus dirujuk dari repo sumber.
- `itlwm.kext/Contents/Info.plist` di arsip **berisi SSID dan sandi WiFi asli**. Jangan pernah dipublikasikan; `prepare-repo.sh` menggantinya dengan placeholder.
- Folder `ACPI` berisi `README_DOWNLOAD_SSDT.txt` (catatan pribadi), jangan ikut dipublikasikan; `prepare-repo.sh` membuangnya.
- `BOOT/BOOTx64.efi` valid sebagai bootstrap OpenCore (memuat `EFI\OC\OpenCore.efi`), jadi susunan `EFI/BOOT` + `EFI/OC` lengkap.
- **Pencocokan hash komponen tanpa lisensi:** `HfsPlus.efi` identik dengan OcBinaryData/master; `USBToolBox.kext` identik dengan rilis resmi 1.2.0; kelima SSDT identik dengan berkas kompilasi Dortania (`SSDT-PLUG` = varian `PLUG-DRTNIA`, `EC-USBX` = `LAPTOP`; catatan unduhan lama menyebut `PLUG-ALT`, yang ternyata untuk Alder Lake). `ECEnabler.kext` **tidak** identik dengan rilis resmi mana pun (terdekat 1.0.4, beda 20 byte; hanya kunci lingkungan build di Info.plist yang berbeda), jadi kemungkinan hasil kompilasi ulang. Tidak ada satu pun dari sumber-sumber itu yang memuat berkas LICENSE.
- **Versi OpenCore terverifikasi 1.0.8 RELEASE.** Hash SHA-256 `OpenCore.efi`, `BOOTx64.efi`, `OpenRuntime.efi`, `OpenCanopy.efi`, dan `ResetNvramEntry.efi` sama persis dengan rilis resmi `OpenCore-1.0.8-RELEASE.zip` (Acidanthera), artinya tidak dimodifikasi. `HfsPlus.efi` tidak ikut dicocokkan (berasal dari OcBinaryData).

## Belum diverifikasi / masalah terbuka
- **Skrip belum diuji di macOS.** `prepare-repo.sh` dan `collect-specs.sh` baru lolos cek sintaks (`bash -n`); tidak pernah dijalankan karena tidak ada macOS. Hal yang perlu diuji: pencarian SSD berdasarkan nama (HONGTAI) dan ukuran EFI (209,7 MB), penggantian nilai PlatformInfo dan WiFi lewat PlistBuddy, dan pola penyaring Bluetooth di `collect-specs.sh` (`awk '/Connected:|Devices \(/{exit}'`, ditulis dari ingatan format `system_profiler`). Jalankan satu kali dan periksa hasilnya sebelum dipercaya.
- **Masalah fungsional terbuka:** (1) sleep/wake tidak berfungsi, layar hitam dan tidak bisa bangun; (2) boot otomatis ke macOS belum stabil, picker memilih Windows. Detail dugaan dan langkah uji ada di bagian "Tidak berfungsi" dan "Belum stabil" di atas; belum ada yang terbukti penyebabnya.

## Perlu tindakan sebelum dipakai orang lain
- Buat SMBIOS sendiri (serial, MLB, UUID, ROM). Nilai di repo ini placeholder.
- Isi `YOUR_SSID` dan `YOUR_PASSWORD` di `itlwm.kext/Contents/Info.plist`, atau pakai HeliPort.
- Pastikan SATA Mode BIOS = AHCI.

## Perangkat keras yang perlu dicek pemilik
- Baterai CMOS lemah: jam BIOS kembali ke 2019 saat daya putus total.
- RAM mungkin single-channel; menambah keping kedua dengan ukuran sama dapat mempercepat iGPU (belum diperiksa).

## Pemeriksaan sebelum mengunggah
- [ ] `PlatformInfo > Generic > ROM` berisi placeholder (`prepare-repo.sh` sekarang mencetak ROM untuk diperiksa).
- [ ] Tidak ada SSID/sandi WiFi asli di seluruh repo: `grep -rniE "ssid|password|serial|uuid" .`
- [ ] File spesifikasi dari `collect-specs.sh` dibaca dulu, tidak ada serial/UUID/MAC.
- [ ] Tabel kredit di `README.md` dicocokkan dengan isi `EFI/`.
- [ ] Lisensi ECEnabler dan `USBToolBox.kext` (tidak ada berkas LICENSE di repo), serta OcBinaryData dan Dortania ACPI, dicek langsung di halaman GitHub-nya oleh pemilik repo.
- [ ] Berkas `config.plist.bak*` tidak ikut (sudah diabaikan `.gitignore`).

## Kondisi baterai
- Laptop uji: sekitar 749 siklus, kapasitas maksimum sekitar 53% dari kapasitas desain (2264 dari 4266 mAh). Ini keausan hardware, bukan masalah konfigurasi.
