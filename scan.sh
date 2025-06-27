#!/bin/bash

# === CONFIGURAÇÃO ===
SUBNET="192.168.1.0/24"
TMP_SCAN_FILE="tmp_scan.txt"
UNV_FILE="unv_cameras.ips"
INTELBRAS_FILE="intelbras_cameras.ips"

# Credenciais Uniview
UNV_USERNAME="admin"
UNV_PASSWORD="Nexo3490!"

# Credenciais Intelbras
INTEL_USERNAME="admin"
INTEL_PASSWORD="Nexo3490"

# === CORES ===
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# === FUNÇÃO: Cabeçalho da tabela ===
print_header() {
  echo
  printf "${CYAN}%-20s | %-10s | %-20s${RESET}\n" "IP" "Fabricante" "Modelo"
  printf "${CYAN}----------------------+------------+----------------------${RESET}\n"
}

# === FUNÇÃO: Linha da tabela ===
print_row() {
  local ip="$1"
  local vendor="$2"
  local model="$3"
  local color="$RESET"

  case "$vendor" in
    "Intelbras") color=$GREEN ;;
    "Uniview")   color=$CYAN ;;
    *)           color=$RED ;;
  esac

  printf "${color}%-20s | %-10s | %-20s${RESET}\n" "$ip" "$vendor" "$model"
}

# === FUNÇÃO: Verifica Uniview ===
is_uniview() {
  local ip="$1"
  local url="http://$ip/LAPI/V1.0/System/DeviceInfo"
  local response
  response=$(curl -s --digest -u "$UNV_USERNAME:$UNV_PASSWORD" "$url")

  if echo "$response" | grep -qE 'DeviceModel|Uniview|IPC'; then
    local model
    model=$(echo "$response" | grep -oP '"DeviceModel"\s*:\s*"\K[^"]+')
    print_row "$ip" "Uniview" "$model"
    echo "$ip" >> "$UNV_FILE"
    return 0
  fi
  return 1
}

# === FUNÇÃO: Verifica Intelbras ===
is_intelbras() {
  local ip="$1"
  local url="http://$ip/cgi-bin/magicBox.cgi?action=getSystemInfo"
  local response
  response=$(curl -s --digest -u "$INTEL_USERNAME:$INTEL_PASSWORD" "$url")

  if echo "$response" | grep -qE "deviceType=|serialNumber="; then
    local model
    model=$(echo "$response" | grep -i "deviceType=" | cut -d= -f2 | tr -d '\r\n' | xargs)
    print_row "$ip" "Intelbras" "$model"
    echo "$ip" >> "$INTELBRAS_FILE"
    return 0
  fi
  return 1
}

# === EXECUÇÃO ===
> "$UNV_FILE"
> "$INTELBRAS_FILE"

echo "[*] Scanning $SUBNET for cameras (port 554)..."
nmap -p 554 --open "$SUBNET" -oG - | awk '/554\/open/ {print $2}' > "$TMP_SCAN_FILE"

echo "[*] Validating camera vendors..."
print_header

while IFS= read -r ip; do
  [[ -z "$ip" ]] && continue

  if is_uniview "$ip"; then
    continue
  elif is_intelbras "$ip"; then
    continue
  else
    print_row "$ip" "Desconhecido" "-"
  fi
done < "$TMP_SCAN_FILE"

rm -f "$TMP_SCAN_FILE"

echo -e "\n${CYAN}[✓] Scan completo. Arquivos gerados:${RESET}"
echo "    - $UNV_FILE (Uniview)"
echo "    - $INTELBRAS_FILE (Intelbras)"
