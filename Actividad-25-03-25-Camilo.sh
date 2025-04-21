#!/bin/bash

# Verificar si se proporciono un argumento
if [ $# -ne 1 ]; then
    echo "Uso: $0 <directorio>"
    exit 1
fi

DIRECTORIO="$1"

# Verificar si el directorio existe
if [ ! -d "$DIRECTORIO" ]; then
    echo "Error: El directorio '$DIRECTORIO' no existe"
    exit 1
fi

# Obtener el nombre del directorio sin la ruta completa
NOMBRE_DIR=$(basename "$DIRECTORIO")

# Nombre del archivo de backup
BACKUP_FILE="backup${NOMBRE_DIR}-$(date '+%Y-%m-%d').tar.gz"

# Crear el backup
tar -czf "$BACKUP_FILE" "$DIRECTORIO"

# Verificar si se creo el archivo correctamente
if [ $? -eq 0 ]; then
    # Registrar en el log
    echo "$(date '+%Y-%m-%d %H:%M:%S') $DIRECTORIO" | sudo tee -a /var/log/backups > /dev/null
    echo "Backup completado: $BACKUP_FILE"
else
    echo "Error al crear el backup"
    exit 1
fi
