#!/bin/bash

# Guardar la salida en un archivo
exec > >(tee -a informacion.txt) 2>&1

archivo="revisar.csv"
usuario="yankees"
timeout=10

# Leer todos los hosts en una lista
mapfile -t hosts < "$archivo"

echo "-------------------------------------"

# Iterar sobre cada host
for host in "${hosts[@]}"; do
    # Eliminar espacios en blanco o saltos de linea al principio y al final
    host=$(echo "$host" | tr -d '[:space:]')

    # Saltar lineas vacias
    [[ -z "$host" ]] && continue

    echo "Intentando conectar como '$usuario' a host '$host' (esperando hasta ${timeout}s)..."

    # Intentar conectarse y ejecutar los comandos guardando la salida
    ssh -o ConnectTimeout=$timeout \
        -o PasswordAuthentication=no \
        -o BatchMode=yes \
        "$usuario@$host" \
        "who; uptime -p" > ssh_output.log 2>&1

    # Verificar si la conexion tuvo exito
    if [[ $? -ne 0 ]]; then
        # Revisar si ssh_output.log contiene errores relacionados con lo que salio mal
        if grep -q "Connection timed out" ssh_output.log; then
            echo "No se pudo conectar con $usuario@$host (timeout)"
        elif grep -q "No route to host" ssh_output.log; then
            echo "No se pudo conectar con $usuario@$host (sin ruta al host)"
        elif grep -q "Connection refused" ssh_output.log; then
            echo "No se pudo conectar con $usuario@$host (conexion rechazada)"
        elif grep -q "Permission denied" ssh_output.log; then
            echo "No se pudo conectar con $usuario@$host (permiso denegado)"
        else
            echo "No se pudo conectar con $usuario@$host (error desconocido)"
        fi
    else
        echo "Conexion exitosa con $host"
        echo "Usuarios conectados:"
        grep -vE "^$" ssh_output.log | grep -v "up"
        echo "Tiempo de actividad:"
        grep "up" ssh_output.log
    fi

    echo "-------------------------------------"
done
