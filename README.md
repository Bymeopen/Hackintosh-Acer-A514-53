# Hackintosh Acer Aspire A514-53 (Core i3 gen 10) — macOS Sequoia

EFI OpenCore 1.0.8 untuk **Acer Aspire A514-53** (Intel Core i3-1005G1, Ice Lake), diuji dengan **macOS Sequoia 15.8.2**.

> **Repo referensi publik dari laptop saya sendiri, bukan paket rilis.** Ini catatan dan salinan EFI dari laptop saya, dibuka agar bisa dijadikan referensi. Tidak ada dukungan dan tidak ada jaminan; hasil di perangkat lain bisa berbeda. Biner di `EFI/` milik pembuat aslinya dan tetap berlisensi aslinya (lihat *Lisensi dan kredit*). Untuk pemakaian sendiri, unduh komponen dari tautan resmi di tabel kredit dan pakai hanya sebagai pembanding.
>
> **Disclaimer.** Saya bukan pemilik atau pembuat file-file di repo ini. Semua komponen (OpenCore, driver, kext, SSDT, dan alat) berasal dari komunitas dan diunduh dari pembuat aslinya. Yang saya lakukan hanya memilih dan menyesuaikannya (`config.plist`, pemetaan USB, kext/SSDT, boot-args) agar laptop saya berjalan normal, lalu melakukan build. Hak cipta tiap komponen milik pembuat masing-masing; lihat bagian *Lisensi dan kredit*.
>
> Repo ini hanya mencatat hal yang sudah terbukti berjalan di laptop saya. Bagian yang belum teruji atau tidak berfungsi ditandai jelas.
> **SMBIOS di repo ini dikosongkan.** Buat serial, MLB, UUID, dan ROM milikmu sendiri (lihat bagian *SMBIOS*). Jangan memakai nilai milik orang lain.

## Spesifikasi laptop

| Komponen | Detail |
|---|---|
| Model | Acer Aspire A514-53 |
| CPU | Intel Core i3-1005G1 (Ice Lake, 10 nm, 2 inti / 4 thread, 1,2 GHz dasar, sampai 3,4 GHz) |
| iGPU | Intel UHD Graphics G1, device-id asli `0x8A56`, di-spoof ke G7 `0x8A52` |
| RAM | 8 GB DDR4-2667 |
| Penyimpanan (macOS) | SSD SATA 2,5" HONGTAI H500 128 GB |
| Penyimpanan (Windows) | SSD NVMe PNY CS2140 2 TB (disk terpisah dari disk macOS) |
| Layar | 14", 1920 x 1080 |
| Audio | Codec Realtek **ALC256** |
| Ethernet | Realtek GbE (kext `RealtekRTL8111`) |
| WiFi | Intel Wi-Fi 6 AX201, ditangani `itlwm` (2,4 GHz dan 5 GHz) |
| Bluetooth | Modul Intel AX201 (USB 8087:0026) |
| Webcam | Quanta HD User Facing (USB) |
| BIOS | InsydeH20, versi V1.16 |
| SMBIOS | MacBookAir9,1 |

## Status

| Fitur | Status |
|---|---|
| Boot macOS Sequoia dari SSD lewat OpenCore | Berfungsi |
| Akselerasi grafis Intel (ICL RVP, 1536 MB) | Berfungsi |
| Ethernet (Realtek) | Berfungsi |
| WiFi 2,4 GHz dan 5 GHz (`itlwm` + HeliPort) | Berfungsi |
| Audio: speaker, jack earphone, mikrofon (`alcid=11`) | Berfungsi |
| Trackpad dan keyboard internal | Berfungsi |
| Kecerahan layar (tombol F) | Berfungsi |
| Baterai (persentase dan status charging) | Terbaca |
| Port USB 2.0 dan USB 3 (5 Gb/s) | Berfungsi |
| Webcam | Terdeteksi di USB, gambar belum dikonfirmasi |
| Bluetooth | Berfungsi dengan TWS (EarFun Air Pro 4, audio terputar) tanpa `IntelBTPatcher`; mouse BT dan HP belum terhubung/belum diuji |
| Boot otomatis ke Macintosh HD (default OpenCore) | Belum stabil |
| Sleep / wake | **Tidak berfungsi** (tidak bisa bangun), sleep dimatikan lewat `pmset` |
| AirDrop, Handoff, Continuity | Tidak tersedia (butuh kartu Broadcom) |
| Instalasi lewat internet recovery (kabel LAN) | Berfungsi |

## Pengaturan BIOS

- **SATA Mode: AHCI.** Di InsydeH20 pilihannya disembunyikan; tekan **Ctrl+S** di tab Main untuk memunculkannya. Nilai bawaan Acer adalah *Optane without RAID*, dan dengan nilai itu macOS tidak melihat disk internal dan Windows gagal boot (0x7B).
- Secure Boot: **nonaktif**
- Fast Boot: **nonaktif**
- Catatan: jika baterai CMOS lemah, BIOS bisa kembali ke nilai pabrik setelah daya putus total (jam kembali ke 2019). Cek SATA Mode setelah itu.

## Hal penting di config.plist

- `Booter > Quirks`: `DevirtualiseMmio = true`, `SetupVirtualMap = false`, `ProtectMemoryRegions = false`, `RebuildAppleMemoryMap = true`, `SyncRuntimePermissions = true`, `AvoidRuntimeDefrag = true`, `EnableSafeModeSlide = true`, `ProvideCustomSlide = true`, `ProtectUefiServices = true`, `EnableWriteUnprotector = false`.
- `Booter > MmioWhitelist`: alamat `4284960280` (0xFF674E18) diaktifkan. Tanpa ini boot mengalami page fault di CR2 `0xFF674E18`.
- `Kernel > Quirks`: `AppleXcpmCfgLock = true`, `DisableIoMapper = true`, `ProvideCurrentCpuInfo = false`.
- iGPU (`PciRoot(0x0)/Pci(0x2,0x0)`): `AAPL,ig-platform-id` = `0000528A`, `device-id` = `528A0000`, ditambah `framebuffer-patch-enable`, `framebuffer-stolenmem`, dan `enable-cdclk-frequency-fix`.
- boot-args: `-v keepsyms=1 -vi2c-force-polling alcid=11 -lilubetaall ipc_control_port_options=0 igfxonln=1 -igfxblr agdpmod=vit9696 -igfxcdc -igfxnotelemetryload watchdog=0`
- Catatan boot-args: `-v keepsyms=1` hanya untuk debug (boleh dihapus setelah stabil). `agdpmod=vit9696` hanya diperlukan untuk GPU diskrit AMD Navi, jadi kemungkinan tidak berpengaruh di laptop ini. `-igfxcdc` mungkin tumpang tindih dengan properti `enable-cdclk-frequency-fix`. `-lilubetaall` hanya perlu jika Lilu menolak versi macOS. Belum diuji satu per satu.
- Jangan memakai `-igfxvesa` atau `-WhateverGreen`: itu memaksa mode VESA tanpa akselerasi grafis (VRAM 7 MB).
- Audio memakai layout `alcid=11` untuk ALC256; layout `69` tidak menghasilkan suara di laptop ini.

## Kext aktif

Lilu, VirtualSMC, SMCProcessor, SMCBatteryManager, WhateverGreen, AppleALC, RestrictEvents, CpuTscSync, BrightnessKeys, ECEnabler, VoodooPS2Controller (+VoodooInput, VoodooPS2Keyboard), VoodooI2C, VoodooI2CHID, VoodooGPIO, VoodooI2CServices, USBToolBox + UTBMap, RealtekRTL8111, itlwm, IntelBluetoothFirmware, BlueToolFixup.

`IntelBTPatcher` ada di folder tetapi **harus tetap dinonaktifkan**: versi 2.4.0 menyebabkan kernel panic (`bluetoothd` -> `IOUSBHostFamily` -> `IntelBTPatcher`) di macOS 15.8.2. `IntelBluetoothFirmware` dan `BlueToolFixup` aktif (`Enabled = true`).

## SSDT

`SSDT-AWAC`, `SSDT-EC-USBX`, `SSDT-PLUG`, `SSDT-PNLF`, `SSDT-XOSI`.

## SMBIOS

Nilai `PlatformInfo > Generic` dikosongkan (`CHANGEME_...`). Buat milikmu dengan [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) untuk model `MacBookAir9,1`, lalu isi `SystemSerialNumber`, `MLB`, `SystemUUID`, dan `ROM`.

## WiFi (itlwm)

`itlwm.kext/Contents/Info.plist` berisi placeholder `YOUR_SSID` dan `YOUR_PASSWORD` di `WiFiConfig`. Isi dengan jaringan WPA2-mu, atau pakai aplikasi [HeliPort](https://github.com/OpenIntelWireless/HeliPort) untuk memilih jaringan. WiFi tidak tersedia di layar recovery, jadi instalasi memakai kabel LAN.

Menu WiFi bawaan macOS akan menampilkan "Mati". Itu normal untuk itlwm; gunakan HeliPort. Tambahkan HeliPort ke Item Login supaya jalan otomatis.

## Instalasi singkat

1. Buat USB recovery Sequoia (`macrecovery`, FAT32 + `com.apple.recovery.boot`), lalu salin folder `EFI` repo ini. (Hanya untuk laptop saya; di perangkat lain sesuaikan dulu.)
2. Isi SMBIOS milikmu, atur BIOS (SATA Mode **AHCI**), boot dari USB, dan pilih **macOS Base System**.
3. Sambungkan kabel LAN, buka Utilitas Disk, hapus disk target (APFS, GUID), lalu jalankan **Instal Ulang macOS Sequoia**. Pastikan yang dihapus adalah disk macOS saja, bukan disk Windows.
4. Setelah terpasang, salin `EFI` ke partisi EFI disk macOS agar bisa boot tanpa USB.

## Dokumen lain

- [`CATATAN-BELUM-LENGKAP.md`](CATATAN-BELUM-LENGKAP.md): yang tidak berfungsi, belum stabil, atau belum dikonfirmasi.
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md): masalah yang pernah terjadi dan cara memperbaikinya.
- [`LICENSE`](LICENSE): lisensi MIT untuk dokumentasi dan skrip saja (lihat bagian *Lisensi dan kredit*).

## Skrip pembantu

- `prepare-repo.sh`: (spesifik untuk laptop ini: mencari SSD bernama HONGTAI dan partisi EFI 209,7 MB; ubah kedua nilai itu untuk mesin lain) menyalin EFI dari SSD macOS (dicari lewat nama model), membuang cadangan, dan mengosongkan serial, MLB, UUID, ROM, serta sandi WiFi.
- `collect-specs.sh`: mengumpulkan spesifikasi perangkat keras dari macOS ke satu file teks, tanpa serial, UUID, atau alamat MAC.

## Peringatan

- Repo ini disediakan apa adanya, tanpa jaminan. Hasil bisa berbeda di perangkat lain, dan semua risiko (kehilangan data, kerusakan, pelanggaran lisensi Apple) ditanggung pengguna sendiri.
- Jangan menjalankan update macOS tanpa mencadangkan folder EFI dan memperbarui OpenCore serta kext dulu. Matikan pembaruan otomatis (lihat `TROUBLESHOOTING.md`).
- Jangan mengaktifkan `IntelBTPatcher` (kernel panic berulang di Sequoia 15.8.2).
- Mati paksa berulang bisa mereset BIOS (lihat bagian BIOS).

## Catatan penggunaan

- Tujuan repo: dokumentasi dan salinan referensi EFI laptop saya (Acer A514-53), dibuka publik sebagai bahan pembanding. Bukan paket siap pakai, tanpa dukungan dan tanpa jaminan.
- Isi `EFI/` sudah dibersihkan dari data pribadi: serial, MLB, UUID, ROM, serta SSID dan sandi WiFi di `itlwm.kext` diganti placeholder, dan `config.plist.bak*` tidak disertakan.
- Lisensi MIT di repo ini hanya untuk dokumentasi dan skrip. Komponen di `EFI/` tetap berlisensi dan berhak cipta pembuat masing-masing (lihat bagian berikut).

## Lisensi dan kredit

**Lisensi repo ini.** Berkas milik repo ini hanyalah dokumentasi dan skrip (`README.md`, `CATATAN-BELUM-LENGKAP.md`, `TROUBLESHOOTING.md`, `prepare-repo.sh`, `collect-specs.sh`) berlisensi [MIT](LICENSE). Lisensi itu **tidak** berlaku untuk perangkat lunak pihak ketiga di folder `EFI/`: tiap bagian tetap di bawah lisensi aslinya dan hak ciptanya milik penulis masing-masing. Cek lisensi di repo sumber sebelum menyebarkan ulang. Lisensinya berbeda-beda (misalnya BSD-3-Clause untuk sebagian besar komponen Acidanthera, APSL 2.0 untuk VoodooPS2, GPL-2.0/GPL-3.0 untuk VoodooI2C, itlwm, dan IntelBluetoothFirmware; kext GPL yang disebarkan bersama EFI mewajibkan sumbernya tetap tersedia), dan satu paket bisa memuat berkas berlisensi lain.

Repo ini tidak berafiliasi dengan Apple, Acer, Intel, atau Acidanthera. macOS adalah merek dagang dan produk Apple; pakailah sesuai perjanjian lisensi Apple.

| Komponen | Pembuat | Lisensi | Sumber |
|---|---|---|---|
| OpenCore (bootloader) | Acidanthera dan kontributor | BSD-3-Clause (sebagian berkas di dalamnya berlisensi lain) | https://github.com/acidanthera/OpenCorePkg |
| Lilu | vit9696 / Acidanthera | BSD-3-Clause | https://github.com/acidanthera/Lilu |
| WhateverGreen | vit9696 / Acidanthera | BSD-3-Clause | https://github.com/acidanthera/WhateverGreen |
| AppleALC | vit9696 / Acidanthera | BSD-3-Clause | https://github.com/acidanthera/AppleALC |
| VirtualSMC (+SMCProcessor, SMCBatteryManager) | vit9696 / Acidanthera | BSD-3-Clause | https://github.com/acidanthera/VirtualSMC |
| RestrictEvents | vit9696 / Acidanthera | BSD-3-Clause | https://github.com/acidanthera/RestrictEvents |
| CpuTscSync | lvs1974 (di repo Acidanthera) | BSD-3-Clause | https://github.com/acidanthera/CpuTscSync |
| BrightnessKeys | zhen-zen (di repo Acidanthera) | BSD-3-Clause | https://github.com/acidanthera/BrightnessKeys |
| ECEnabler | averycblack (sebelumnya 1Revenger1) | Tanpa lisensi tercantum. Kredit: averycblack (1Revenger1). Unduh: https://github.com/1Revenger1/ECEnabler/releases | https://github.com/1Revenger1/ECEnabler |
| VoodooPS2 (+VoodooPS2Keyboard) | Acidanthera dan kontributor (berbasis karya RehabMan dkk.) | APSL 2.0 | https://github.com/acidanthera/VoodooPS2 |
| VoodooInput | Acidanthera dan kontributor | GPL-2.0 | https://github.com/acidanthera/VoodooInput |
| VoodooI2C, VoodooI2CHID (VoodooGPIO dan VoodooInputMultitouch ikut di dalam paket VoodooI2C) | VoodooI2C dan kontributor | GPL-3.0 (VoodooI2C, VoodooGPIO). VoodooI2CHID: tanpa lisensi sendiri tercantum, kredit VoodooI2C/alexandred, unduh bersama VoodooI2C: https://github.com/VoodooI2C/VoodooI2C/releases | https://github.com/VoodooI2C |
| itlwm, HeliPort, IntelBluetoothFirmware, IntelBTPatcher | OpenIntelWireless | itlwm GPL-2.0; HeliPort BSD-3-Clause; IntelBluetoothFirmware GPL-3.0. IntelBTPatcher: tanpa lisensi sendiri tercantum, kredit OpenIntelWireless/zxystd, unduh: https://github.com/OpenIntelWireless/IntelBluetoothFirmware/releases (dirilis bersama IntelBluetoothFirmware) | https://github.com/OpenIntelWireless |
| BlueToolFixup | Acidanthera (paket BrcmPatchRAM) | GPL-2.0 (LICENSE repo BrcmPatchRAM) | https://github.com/acidanthera/BrcmPatchRAM |
| USBToolBox.kext dan alat pembuat peta USB; `UTBMap.kext` dihasilkan untuk laptop ini | USBToolBox (dhinakg dan kontributor) | Alat pembuat peta: MIT. Kext: tanpa lisensi tercantum, kredit USBToolBox/dhinakg, unduh: https://github.com/USBToolBox/kext/releases | https://github.com/USBToolBox |
| RealtekRTL8111 | Mieze | GPL-2.0 (kata README repo: "published under GPLv2") | https://github.com/Mieze/RTL8111_driver_for_OS_X |
| SSDT-AWAC, SSDT-EC-USBX, SSDT-PLUG, SSDT-PNLF, SSDT-XOSI (berkas `.aml` siap pakai) | Dortania, repo Getting-Started-With-ACPI (`extra-files/compiled`) | Tanpa lisensi tercantum. Kredit: Dortania. Unduh: https://github.com/dortania/Getting-Started-With-ACPI/tree/master/extra-files/compiled | https://github.com/dortania/Getting-Started-With-ACPI |
| Driver UEFI: OpenRuntime, OpenCanopy, ResetNvramEntry | Acidanthera (OpenCorePkg) | BSD-3-Clause (OpenCorePkg) | https://github.com/acidanthera/OpenCorePkg |
| HfsPlus.efi (driver sistem berkas) | Acidanthera (OcBinaryData); HfsPlus asli dari Apple/VMware | Lisensi terpisah (HfsPlus asli: Apple/VMware). Kredit: Acidanthera. Unduh: https://github.com/acidanthera/OcBinaryData | https://github.com/acidanthera/OcBinaryData |
| `OC/Resources` (gambar dan suara OpenCanopy) | Acidanthera (OcBinaryData) | Tanpa lisensi tercantum. Kredit: Acidanthera. Unduh: https://github.com/acidanthera/OcBinaryData | https://github.com/acidanthera/OcBinaryData |
| `BOOT/BOOTx64.efi` | Acidanthera (OpenCorePkg) | BSD-3-Clause (OpenCorePkg) | https://github.com/acidanthera/OpenCorePkg |
| SSDTTime (opsional, untuk membuat SSDT) | corpnewt | MIT | https://github.com/corpnewt/SSDTTime |
| GenSMBIOS | corpnewt | MIT | https://github.com/corpnewt/GenSMBIOS |
| macrecovery | Acidanthera (bagian OpenCorePkg) | BSD-3-Clause (OpenCorePkg) | https://github.com/acidanthera/OpenCorePkg |
| Panduan instalasi (hanya dirujuk, isinya tidak disalin) | Dortania, OpenCore Install Guide | CC BY-NC-SA 4.0 (nonkomersial) | https://dortania.github.io/OpenCore-Install-Guide/ |

Daftar komponen sudah dicocokkan dengan arsip `OC` dan folder `BOOT` dari EFI laptop (20 kext, 5 SSDT, 4 driver, `Resources`, `BOOT/BOOTx64.efi`) beserta `config.plist`-nya: semua entri di config ada di disk dan sebaliknya, SSDT valid (tanda tangan dan checksum), dan semua biner kext berformat Mach-O. `BOOTx64.efi` (24.576 B) adalah bootstrap OpenCore yang valid (berformat PE dan memuat `EFI\OC\OpenCore.efi`), ditemani `.contentFlavour` (OpenCore) dan `.contentVisibility` (Disabled). Nomor versi kext dibaca dari `Info.plist` masing-masing, dan nama pembuat dilengkapi dari bundle ID. **OpenCore 1.0.8 RELEASE terverifikasi:** hash SHA-256 `OpenCore.efi`, `BOOTx64.efi`, `OpenRuntime.efi`, `OpenCanopy.efi`, dan `ResetNvramEntry.efi` identik dengan berkas di rilis resmi `OpenCore-1.0.8-RELEASE.zip` dari Acidanthera. Jadi kelima berkas itu tidak dimodifikasi. (Versi tidak terbaca dari string di dalam berkasnya karena memuat templat `REL-XXX-YYYY-MM-DD`; pencocokan dilakukan lewat hash.)

Kolom lisensi yang berisi nama lisensi dicocokkan dengan berkas LICENSE di cabang utama repo sumber (jenis lisensi dikenali dari teksnya; sebagian paket memuat berkas berlisensi lain). Untuk komponen yang lisensinya tidak lengkap atau tidak ada, yang dicantumkan adalah kredit pembuat dan tautan unduh resminya. Itu adalah keterangan asal-usul, bukan pemberian izin: hak cipta tetap pada pembuatnya. Biner komponen-komponen itu ada di `EFI/` sebagai referensi, dan tetap tunduk pada ketentuan pembuatnya (termasuk izin dan kewajiban GPL untuk kext GPL). Siapa pun yang ingin memakainya sebaiknya mengunduh sendiri dari tautan resmi dan mengikuti ketentuan pembuatnya.

**Versi komponen terpasang**

| Kext | Versi | Bundle ID (petunjuk pembuat) |
|---|---|---|
| Lilu | 1.7.2 | as.vit9696.Lilu |
| VirtualSMC / SMCProcessor / SMCBatteryManager | 1.3.8 | as.vit9696 / ru.usrsse2 |
| WhateverGreen | 1.7.1 | as.vit9696.WhateverGreen |
| AppleALC | 1.9.6 | as.vit9696.AppleALC |
| RestrictEvents | 1.1.7 | as.vit9696.RestrictEvents |
| BrightnessKeys | 1.0.4 | as.acidanthera.BrightnessKeys |
| CpuTscSync | 1.1.3 | org.lvs1974.driver.CpuTscSync |
| ECEnabler | 1.0.6 | com.1Revenger1.ECEnabler |
| VoodooPS2Controller (+VoodooInput, VoodooPS2Keyboard) | 2.3.8 | as.acidanthera.voodoo.driver.PS2Controller |
| VoodooI2C (+VoodooGPIO, VoodooI2CServices) | 2.9.1 | com.alexandred.VoodooI2C |
| VoodooI2CHID | 1.0 | com.alexandred.VoodooI2CHID |
| USBToolBox | 1.2.0 | com.dhinakg.USBToolBox.kext |
| UTBMap (peta USB laptop ini) | 1.1 | com.dhinakg.USBToolBox.map |
| itlwm | 2.3.0 | com.zxystd.itlwm |
| IntelBluetoothFirmware / IntelBTPatcher | 2.4.0 | com.zxystd |
| BlueToolFixup | 2.7.2 | as.acidanthera.BlueToolFixup |
| RealtekRTL8111 | 2.4.2 | com.insanelymac.RealtekRTL8111 |

**Komponen yang lisensinya belum ditemukan.** Untuk komponen ini, kredit pembuat dan tautan unduh di bawah dicantumkan sebagai keterangan asal-usul pengganti lisensi (bukan pemberian izin). Semua komponen ini milik pembuat aslinya dan diunduh dari sumber di bawah; repo ini tidak mengklaim hak apa pun atasnya. Kalau Anda ingin memakai ulang, baca dan ikuti lisensi di tautan masing-masing, atau tanyakan ke pembuatnya.

| Komponen | Pembuat | Sumber | Keterangan |
|---|---|---|---|
| ECEnabler | averycblack (sebelumnya 1Revenger1) | https://github.com/1Revenger1/ECEnabler | Tidak ada berkas LICENSE yang ditemukan |
| USBToolBox.kext | USBToolBox (dhinakg dan kontributor) | https://github.com/USBToolBox/kext | Tidak ada LICENSE di repo kext; alat pembuat peta (https://github.com/USBToolBox/tool) berlisensi MIT |
| OcBinaryData (HfsPlus.efi dan `OC/Resources`) | Acidanthera | https://github.com/acidanthera/OcBinaryData | Lisensi tidak terbaca dari sini; HfsPlus asli berasal dari Apple/VMware |
| SSDT Dortania (AWAC, EC-USBX, PLUG, PNLF, XOSI) | Dortania | https://github.com/dortania/Getting-Started-With-ACPI | Lisensi repo tidak terbaca dari sini |
| VoodooI2CHID | VoodooI2C dan kontributor | https://github.com/VoodooI2C/VoodooI2C | Diasumsikan ikut paket VoodooI2C (GPL-3.0), belum terverifikasi |
| IntelBTPatcher | OpenIntelWireless | https://github.com/OpenIntelWireless/IntelBluetoothFirmware | Diasumsikan ikut paket IntelBluetoothFirmware (GPL-3.0), belum terverifikasi |

**Unduhan asli untuk tiga biner tanpa lisensi tercantum.** `ECEnabler.kext`, `USBToolBox.kext`, dan `HfsPlus.efi` tetap disertakan di `EFI/` sebagai referensi. Hak ciptanya milik pembuat masing-masing; sumber dan unduhan aslinya:

| Biner di repo ini | Pembuat | Unduhan asli |
|---|---|---|
| `EFI/OC/Kexts/ECEnabler.kext` (v1.0.6) | averycblack (1Revenger1) | https://github.com/1Revenger1/ECEnabler/releases |
| `EFI/OC/Kexts/USBToolBox.kext` (build 1.2.0) | USBToolBox (dhinakg dan kontributor) | https://github.com/USBToolBox/kext/releases |
| `EFI/OC/Drivers/HfsPlus.efi` | Acidanthera (OcBinaryData); asli dari Apple/VMware | https://github.com/acidanthera/OcBinaryData/blob/master/Drivers/HfsPlus.efi |

**Hasil pencocokan hash (SHA-256) dengan sumber asli:**

| Biner | Hasil |
|---|---|
| `HfsPlus.efi` | Identik dengan `Drivers/HfsPlus.efi` di OcBinaryData (cabang `master`). Repo OcBinaryData tidak memuat berkas LICENSE atau README di akarnya yang bisa saya baca. |
| `USBToolBox.kext` | Biner dan `Info.plist` identik dengan rilis resmi `USBToolBox-1.2.0-RELEASE.zip`. Rilis dan repo kext tidak memuat berkas LICENSE. |
| `ECEnabler.kext` | **Tidak** identik dengan rilis resmi 1.0.x mana pun. Terdekat dengan 1.0.4 (hanya 20 byte beda) dan 683 byte beda dari 1.0.6; `Info.plist` hanya berbeda pada kunci lingkungan build (Xcode dan SDK). Jadi kemungkinan ini hasil kompilasi ulang dari sumber yang sama (bukan unduhan rilis), meski Info.plist menyebut versi 1.0.6. Rilis resmi tidak memuat berkas LICENSE. |
| 5 SSDT | Identik dengan berkas kompilasi Dortania (`extra-files/compiled`): `SSDT-AWAC`, `SSDT-PNLF`, `SSDT-XOSI`, `SSDT-EC-USBX` = varian `LAPTOP`, dan `SSDT-PLUG` = `SSDT-PLUG-DRTNIA`. Repo Getting-Started-With-ACPI hanya memuat README, tanpa LICENSE. |

Pakailah unduhan dari tautan resmi itu untuk keperluan sendiri, dan jika pembuat keberatan binernya ada di sini, saya akan menghapusnya.

Jika Anda pemilik salah satu komponen di atas dan kreditnya salah atau kurang, silakan buka issue dan akan segera diperbaiki.
