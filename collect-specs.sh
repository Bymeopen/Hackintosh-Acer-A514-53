#!/bin/zsh
# Mengumpulkan spesifikasi perangkat keras dari macOS ke ~/Desktop/spesifikasi-A514-53.txt
# Hanya membaca. Baris yang memuat serial, UUID, atau alamat MAC dibuang.
# Jalankan: zsh collect-specs.sh

OUT=~/Desktop/spesifikasi-A514-53.txt
FILTER='Serial|UUID|MAC Address|Provisioning|Boot ROM|Address:|Computer Name|User Name|Host Name'

{
  echo "=== Ringkasan ==="
  sw_vers
  sysctl -n machdep.cpu.brand_string
  sysctl -n hw.memsize | awk '{printf "RAM: %.0f GB\n", $1/1073741824}'
  echo
  echo "=== Perangkat keras ==="
  system_profiler SPHardwareDataType
  echo "=== Grafis dan layar ==="
  system_profiler SPDisplaysDataType
  echo "=== Audio ==="
  system_profiler SPAudioDataType
  echo "=== Penyimpanan ==="
  system_profiler SPNVMeDataType SPSerialATADataType
  echo "=== PCI ==="
  system_profiler SPPCIDataType
  echo "=== USB ==="
  system_profiler SPUSBDataType
  echo "=== Bluetooth ==="
  # Hanya info pengendali; daftar perangkat yang dipasangkan (nama pribadi) dibuang
  system_profiler SPBluetoothDataType | awk '/Connected:|Devices \(/{exit} {print}'
  echo "=== Jaringan ==="
  networksetup -listallhardwareports | grep -v "Ethernet Address"
  echo "=== Baterai ==="
  pmset -g batt
} 2>/dev/null | grep -v -E "$FILTER" > "$OUT"

echo "Tersimpan: $OUT"
echo "Periksa isinya sebelum dibagikan."
