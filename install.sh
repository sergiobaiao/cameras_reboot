#!/bin/bash

DEST="/opt/nexo"
REPO_URL="https://github.com/sergiobaiao/cameras_reboot"
SCRIPT_PATH="$DEST/reboot_cameras.sh"
LOG_FILE="/var/log/cameras_cron.log"

echo "[INFO] Criando diretório $DEST..."
sudo mkdir -p "$DEST"

echo "[INFO] Clonando repositório..."
if [ -d "$DEST/.git" ]; then
    cd "$DEST" && sudo git pull
else
    sudo git clone "$REPO_URL" "$DEST"
fi

echo "[INFO] Tornando scripts executáveis..."
sudo chmod +x "$DEST/"*.sh

echo "[INFO] Instalando cron para reboot_cameras.sh..."
(crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH" ; echo "0 5 * * * $SCRIPT_PATH >> $LOG_FILE 2>&1") | crontab -

echo "[✅] Instalação concluída em $DEST. O reboot será feito diariamente às 05h."
