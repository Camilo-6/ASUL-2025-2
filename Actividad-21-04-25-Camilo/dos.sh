#!/bin/bash

archivo="revisar.csv"
usuario="yankees"
timeout=20
private_key_path="~/.ssh/id_rsa"

# Leer todos los hosts en una lista
mapfile -t hosts < "$archivo"

# Iterar sobre cada host
for host in "${hosts[@]}"; do
    # Eliminar espacios en blanco o saltos de linea al principio y al final
    host=$(echo "$host" | xargs)
    echo "Host:$host"

    # Saltar lineas vacias
    [[ -z "$host" ]] && continue

    echo "Intentando conectar como '$usuario' a host '$host' (esperando hasta ${timeout}s)..."

    # Intentar conectarse y ejecutar comandos
    ssh -i "$private_key_path" -o ConnectTimeout=$timeout "$usuario@$host" << EOF
        echo "✅ Conexion exitosa con '$host'"
        echo "👥 Usuarios conectados:"
        who
        echo "🕒 Tiempo de actividad:"
        uptime -p
EOF

    # Verificar si la conexion tuvo exito
    if [[ $? -ne 0 ]]; then
        echo "No se pudo conectar con $usuario@$host (apagado, inaccesible o sin clave publica autorizada)"
    fi

    echo "--------------------------"
done