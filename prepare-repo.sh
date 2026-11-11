#!/bin/zsh
# Menyiapkan folder EFI bersih untuk diunggah ke GitHub.
# Jalankan di macOS: zsh prepare-repo.sh
# Hasil: ~/Desktop/Hackintosh-A514-53/EFI  (tanpa backup, log, serial, MLB, UUID, ROM, dan sandi WiFi)
# Hanya MEMBACA dari EFI SSD macOS. Tidak menyentuh disk Windows.

OUT=~/Desktop/Hackintosh-A514-53

# 1. Cari SSD macOS lewat nama model (nomor disk bisa bergeser antar boot)
D=$(for d in $(diskutil list | awk '/^\/dev\/disk/{gsub("/dev/","",$1); print $1}'); do
  diskutil info $d 2>/dev/null | grep -q HONGTAI && { echo $d; break; }
done)
[ -n "$D" ] || { echo "BERHENTI: SSD HONGTAI tidak ditemukan"; exit 1; }
E=${D}s1
diskutil info $E | grep -q "209.7 MB" || { echo "BERHENTI: $E bukan partisi EFI 209,7 MB"; exit 1; }
sudo diskutil mount $E >/dev/null || { echo "BERHENTI: gagal mount $E"; exit 1; }
M=$(diskutil info $E | awk -F': *' '/Mount Point/{print $2}')
[ -d "$M/EFI/OC" ] || { echo "BERHENTI: folder EFI/OC tidak ada di $M"; exit 1; }

# 2. Salin EFI ke folder repo
mkdir -p "$OUT"
rm -rf "$OUT/EFI.baru"
ditto "$M/EFI" "$OUT/EFI.baru" || { echo "BERHENTI: gagal menyalin"; exit 1; }
rm -rf "$OUT/EFI"; mv "$OUT/EFI.baru" "$OUT/EFI"
sleep 3
sudo diskutil unmount force $E >/dev/null

# 3. Buang file sampah
find "$OUT" -name "config.plist.bak*" -delete
find "$OUT" -name "config.plist.rusak*" -delete
find "$OUT" -name ".DS_Store" -delete
find "$OUT" \( -name "*.bak" -o -name "*.log" \) -delete
find "$OUT" -name "opencore-*.txt" -delete
find "$OUT" -name "README_DOWNLOAD_SSDT.txt" -delete

# 4. Kosongkan data pribadi di config.plist
C="$OUT/EFI/OC/config.plist"
PB=/usr/libexec/PlistBuddy
$PB -c "Set :PlatformInfo:Generic:SystemSerialNumber CHANGEME_SERIAL" "$C" || echo "peringatan: SystemSerialNumber tidak ditemukan"
$PB -c "Set :PlatformInfo:Generic:MLB CHANGEME_MLB" "$C"                   || echo "peringatan: MLB tidak ditemukan"
$PB -c "Set :PlatformInfo:Generic:SystemUUID 00000000-0000-0000-0000-000000000000" "$C" || echo "peringatan: SystemUUID tidak ditemukan"
$PB -c "Set :PlatformInfo:Generic:ROM CHANGE" "$C"                          || echo "peringatan: ROM tidak ditemukan"

# 5. Ganti WiFi di itlwm dengan placeholder
K="$OUT/EFI/OC/Kexts/itlwm.kext/Contents/Info.plist"
B=:IOKitPersonalities:itlwm:WiFiConfig
if [ -f "$K" ]; then
  $PB -c "Delete $B" "$K" 2>/dev/null
  $PB -c "Add $B dict" -c "Add $B:WiFi_1 dict" -c "Add $B:WiFi_1:ssid string YOUR_SSID" -c "Add $B:WiFi_1:password string YOUR_PASSWORD" "$K"
fi

# 6. Periksa hasilnya
echo "--- PlatformInfo ---"
for k in SystemProductName SystemSerialNumber MLB SystemUUID ROM; do
  printf "%s = " $k; $PB -c "Print :PlatformInfo:Generic:$k" "$C"
done
echo "--- WiFi itlwm (harus YOUR_SSID / YOUR_PASSWORD) ---"
$PB -c "Print $B" "$K"
echo "--- Kext aktif ---"
for i in $(seq 0 60); do
  p=$($PB -c "Print :Kernel:Add:$i:BundlePath" "$C" 2>/dev/null) || break
  e=$($PB -c "Print :Kernel:Add:$i:Enabled" "$C")
  [ "$e" = "true" ] && echo "  $p"
done
echo "--- Isi folder ---"
ls "$OUT/EFI" "$OUT/EFI/OC"
echo "Selesai: $OUT"
echo "Periksa sekali lagi tidak ada serial, MLB, UUID, ROM, atau sandi WiFi aslimu sebelum diunggah."
