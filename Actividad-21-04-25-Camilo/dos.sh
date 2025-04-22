#!/bin/bash

archivo="revisar.csv"
usuario="yankees"
timeout=20
private_key_path="~/.ssh/id_rsa"

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
    ssh -i "$private_key_path" \
        -o ConnectTimeout=$timeout \
        -o PasswordAuthentication=no \
        -o BatchMode=yes \
        "$usuario@$host" \
        "who; uptime -p" > ssh_output.log 2>&1

    # Verificar si la conexion tuvo exito
    if [[ $? -ne 0 ]]; then
        echo "No se pudo conectar con $usuario@$host (apagado, inaccesible o sin clave publica autorizada)"
    else
        # Revisar si se pidio la contrasenia
        if grep -q "password:" ssh_output.log; then
            echo "Conexion fallida: SSH pidio contrasenia para $host"
        else
            echo "Conexion exitosa con $host"
            echo "Usuarios conectados:"
            grep -vE "^$" ssh_output.log | grep -v "up"
            echo "Tiempo de actividad:"
            grep "up" ssh_output.log
        fi
    fi

    # Verificar si ssh_output.log contiene errores relacionados con la inaccesibilidad del host
    if grep -q "Connection timed out" ssh_output.log || grep -q "No route to host" ssh_output.log || grep -q "Connection refused" ssh_output.log; then
        echo "La maquina $host no esta disponible o inaccesible"
    fi

    echo "-------------------------------------"
done
