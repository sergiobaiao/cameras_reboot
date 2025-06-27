#!/bin/bash

UNV_USERNAME="admin"
UNV_PASSWORD="Nexo3490!"

INTEL_USERNAME="admin"
INTEL_PASSWORD="Nexo3490"

UNV_FILE="unv_cameras.ips"
INTELBRAS_FILE="intelbras_cameras.ips"
LOG_FILE="cameras.log"
JSON_FILE="cameras.jsonl"

# Cores
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# Função de log
log() {
  local msg="$1"
  echo -e "$msg" | tee -a "$LOG_FILE"
}

# Função JSON
write_json() {
  local ip="$1"
  local brand="$2"
  local status="$3"
  echo "{\"ip\": \"$ip\", \"brand\": \"$brand\", \"status\": \"$status\", \"timestamp\": \"$(date +'%F %T')\"}" >> "$JSON_FILE"
}

# Função reboot Uniview
reboot_uniview() {
  local ip="$1"
  local url="http://$ip/LAPI/V1.0/System/Reboot"
  local res
  res=$(curl -s -o /dev/null -w "%{http_code}" --digest -u "$UNV_USERNAME:$UNV_PASSWORD" -X PUT "$url")

  if [[ "$res" == "200" ]]; then
    log "[${CYAN}UNV${RESET}] 🔄 ${ip} rebooted successfully."
    write_json "$ip" "Uniview" "success"
  else
    log "[${CYAN}UNV${RESET}] ❌ Failed to reboot ${ip} (HTTP $res)"
    write_json "$ip" "Uniview" "fail"
  fi
}

# Função reboot Intelbras
reboot_intelbras() {
  local ip="$1"
  local url="http://$ip/cgi-bin/magicBox.cgi?action=reboot"
  local res
  res=$(curl -s -o /dev/null -w "%{http_code}" --digest -u "$INTEL_USERNAME:$INTEL_PASSWORD" "$url")

  if [[ "$res" == "200" ]]; then
    log "[${GREEN}INT${RESET}] 🔄 ${ip} rebooted successfully."
    write_json "$ip" "Intelbras" "success"
  else
    log "[${GREEN}INT${RESET}] ❌ Failed to reboot ${ip} (HTTP $res)"
    write_json "$ip" "Intelbras" "fail"
  fi
}

# Limpa arquivos antigos
> "$LOG_FILE"
> "$JSON_FILE"

log "[🟢] Iniciando reboot de câmeras..."
log "-----------------------------------------"

# Uniview
if [[ -f "$UNV_FILE" ]]; then
  while IFS= read -r ip; do
    [[ -z "$ip" ]] && continue
    reboot_uniview "$ip"
  done < "$UNV_FILE"
fi

# Intelbras
if [[ -f "$INTELBRAS_FILE" ]]; then
  while IFS= read -r ip; do
    [[ -z "$ip" ]] && continue
    reboot_intelbras "$ip"
  done < "$INTELBRAS_FILE"
fi

log "-----------------------------------------"
log "[✅] Processo finalizado. Logs: $LOG_FILE | Resultados JSONL: $JSON_FILE"
