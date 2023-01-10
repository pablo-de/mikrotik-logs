#!/bin/bash

#Variables
log_file="/var/log/mikrotik.log"
BOT_TOKEN="<your bot token>"
CHAT_ID="<your chat ID>"

# Archivo donde se almacenarán los errores anteriores. Crear con 'touch error/logins.txt'
errors_file='./errors.txt'
logins_file='./logins.txt'

# Usamos el comando "grep" para buscar las líneas que contengan la palabra "critical" o "account" en el archivo
lines=$(grep -i "critical\|account" "$log_file")

# Recorremos cada línea de la salida de grep
while read -r line; do
    if [[ "$line" == *"critical"* ]]; then
        message=$(echo "$line" | sed 's/^[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *//')
        message="Mikrotik: $message"
        # Comprobamos si la línea ya está en el archivo de errores
        if ! grep -q "$line" "$errors_file"; then
            # Si la línea no está en el archivo, la añadimos y enviamos un mensaje de Telegram
            echo "$line" >>"$errors_file"
            # Enviar el mensaje
            curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d parse_mode=Markdown -d text="$message" >/dev/null
        fi
    elif [[ "$line" == *"account"* ]]; then
        message=$(echo "$line" | sed 's/^[^ ]* *[^ ]* *[^ ]* *[^ ]* *[^ ]* *//')
        message="Mikrotik: $message"
        # Comprobamos si la línea ya está en el archivo de logins
        if ! grep -q "$line" "$logins_file"; then
            # Si la línea no está en el archivo, la añadimos y enviamos un mensaje de Telegram
            echo "$line" >>"$logins_file"
            # Enviar el mensaje
            curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d parse_mode=Markdown -d text="$message" >/dev/null
        fi
    fi
done <<<"$lines"
