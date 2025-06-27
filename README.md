# cameras_reboot

Scripts para detecção, reboot e monitoramento de câmeras Uniview e Intelbras.

## Instalação

Execute no terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/sergiobaiao/cameras_reboot/main/install.sh)
```

## Scripts incluídos

- `scan.sh`: Detecta câmeras na rede e separa por fabricante
- `reboot_cameras.sh`: Reboot diário das câmeras
- `viewlog.sh`: Exibe log de status das câmeras com base no arquivo JSON gerado
