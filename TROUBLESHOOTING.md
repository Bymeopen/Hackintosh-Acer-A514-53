# Troubleshooting Acer Aspire A514-53 (i3-1005G1)

## macOS tidak melihat disk, atau Windows biru 0x7B (INACCESSIBLE_BOOT_DEVICE)
Penyebab: SATA Mode BIOS kembali ke bawaan **Optane without RAID** (Intel RST), biasanya setelah mati paksa atau daya putus total.
1. F2 masuk BIOS. Di tab **Main** tekan **Ctrl+S** untuk memunculkan opsi SATA Mode.
2. Ubah ke **AHCI**, simpan dengan F10.
3. Jika Windows tetap biru karena dulu dipasang di mode Optane: dari menu pemulihan Windows (Troubleshoot > Advanced options > Command Prompt) jalankan `bcdedit /set {default} safeboot minimal`, boot ke Safe Mode (driver AHCI dimuat), lalu di Command Prompt Admin jalankan `bcdedit /deletevalue {current} safeboot` dan restart.

## BIOS terus kembali ke nilai pabrik / jam 2019
Kemungkinan baterai CMOS lemah. Ganti baterai koin CMOS (CR2032). Di tab Main ada opsi *Real Time Clock reset*; nilai Enabled ikut dicurigai, tetapi perilakunya belum dipastikan.

## Grafis hanya 7 MB / tanpa akselerasi
Hapus `-igfxvesa` dan `-WhateverGreen` dari boot-args. Dengan keduanya, macOS memakai mode VESA.

## Page fault di CR2 0xFF674E18
`Booter > Quirks > DevirtualiseMmio = true` dan whitelist alamat `4284960280` di `Booter > MmioWhitelist`.

## Audio tidak berbunyi
Codec ALC256. Layout `alcid=11` berfungsi (speaker, earphone, mikrofon); `69` tidak. Jika codec/layout lain, coba layout ALC256 lain satu per satu dan restart di antaranya.

## WiFi
Pakai `itlwm` (bukan AirportItlwm). Menu WiFi bawaan macOS menampilkan "Mati"; itu normal. Isi SSID/sandi di `Info.plist` kext atau pakai HeliPort, dan tambahkan HeliPort ke Item Login. Jika HeliPort tidak muncul setelah restart, buka lagi dari folder Aplikasi.

## Pilihan default OpenCore tidak tersimpan
Cek `Misc > Security > AllowSetDefault = true`, lalu tekan **Ctrl+Enter** pada Macintosh HD. Jika tetap memilih Windows setelah restart, kemungkinan NVRAM tidak ditulis firmware InsydeH20 atau ditimpa Windows Boot Manager. `LauncherOption = Full` dan `RequestBootVarRouting = true` sudah diatur di config; coba jadikan disk macOS prioritas pertama di menu boot BIOS. Perilaku ini belum dipastikan.

## Update macOS
Jangan memperbarui macOS tanpa mencadangkan folder EFI dan memperbarui OpenCore serta kext terlebih dahulu. Nonaktifkan pembaruan otomatis:
`sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false`

## Cadangan EFI
Salin partisi EFI SSD macOS (`diskutil mount`, lalu `cp -R /Volumes/EFI/EFI ~/Desktop/EFI-backup`) ke flashdisk atau cloud. Folder itu berisi serial, MLB, UUID, ROM, dan sandi WiFi; jangan dipublikasikan.

## Kernel panic saat memakai Bluetooth (IntelBTPatcher)
Gejala: Bluetooth menyala dan scan jalan, lalu menyambung ke perangkat membuat Bluetooth mati-hidup atau kernel panic berulang. Backtrace memuat `com.zxystd.IntelBTPatcher`, `IOUSBHostFamily`, dan thread `bluetoothd`.
Penyebab: `IntelBTPatcher` 2.4.0 di macOS 15.8.2. Solusi: set `Enabled = false` pada `IntelBTPatcher.kext` di `config.plist`.
Jika Mac panic terus sebelum sempat diperbaiki, edit config dari luar: boot flashdisk/Recovery, atau mount EFI SSD dari Windows (`diskpart`, `select volume N`, `assign letter=R`), lalu ubah `Enabled` blok `IntelBTPatcher.kext` menjadi `<false/>`. Pastikan yang di-mount EFI SSD macOS, bukan EFI flashdisk atau EFI Windows. Cadangkan `config.plist` dulu.

## Mematikan pembaruan macOS otomatis
```
P=/Library/Preferences/com.apple.SoftwareUpdate
sudo defaults write $P AutomaticCheckEnabled -bool false
sudo defaults write $P AutomaticDownload -bool false
sudo defaults write $P AutomaticallyInstallMacOSUpdates -bool false
sudo defaults write $P ConfigDataInstall -bool false
sudo defaults write $P CriticalUpdateInstall -bool false
```
Matikan juga notifikasi Pembaruan Perangkat Lunak di Pengaturan Sistem > Notifikasi.
