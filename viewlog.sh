#!/bin/bash

FILE="cameras.jsonl"

GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

echo -e "${CYAN}=== Summary Report ===${RESET}"

# Contagem total de entradas válidas
total=$(grep -E '^\{.*\}$' "$FILE" | jq -r '.' | wc -l)
echo "Total entries: $total"

# Câmeras com sucesso
echo -e "\n${GREEN}Cameras rebooted successfully:${RESET}"
grep -E '^\{.*\}$' "$FILE" | jq -r 'select(.status == "success") | "\(.ip) (\(.brand))"' || echo "Nenhuma"

# Câmeras com falha
echo -e "\n${RED}Cameras that failed to reboot:${RESET}"
grep -E '^\{.*\}$' "$FILE" | jq -r 'select(.status == "fail") | "\(.ip) (\(.brand))"' || echo "Nenhuma"
