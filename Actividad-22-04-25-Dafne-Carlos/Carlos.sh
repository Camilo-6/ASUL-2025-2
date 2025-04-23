#!/bin/bash

HOSTS=(
    "rojo"
    "yankees"
    "debianito"
    "supernova"
    "ggDebian"
    "fer"
    "EquipoNoSe"
    "viltrum"
    "debian1"
)

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="reporte_estado_${TIMESTAMP}.txt"
TMP_DIR=$(mktemp -d) 

echo "Iniciando verificaciones en ${#HOSTS[@]} hosts..." | tee -a "$OUTPUT_FILE"
echo "Resultados guardados en: $OUTPUT_FILE"
echo "-------------------------------------" | tee -a "$OUTPUT_FILE"

pids=()
for host in "${HOSTS[@]}"; do
    (
        echo "Verificando host: $host ..."

        if ping -c 1 -W 1 "$host" > /dev/null 2>&1; then
            echo "Host: $host - ESTADO: ACTIVO" > "$TMP_DIR/$host.status"
            ssh_opts="-o ConnectTimeout=5 -o StrictHostKeyChecking=no -o BatchMode=yes"
            
            echo "--- Usuarios Conectados ---" > "$TMP_DIR/$host.users"
            if ssh $ssh_opts "$host" "who" >> "$TMP_DIR/$host.users" 2> "$TMP_DIR/$host.ssh_error"; then
                if ! [[ -s "$TMP_DIR/$host.users" ]]; then
                     echo "(ninguno)" >> "$TMP_DIR/$host.users"
                fi
            else
                echo "Error SSH (who): $(cat "$TMP_DIR/$host.ssh_error")" >> "$TMP_DIR/$host.users"
            fi

            echo "--- Uptime ---" > "$TMP_DIR/$host.uptime"
             if ! ssh $ssh_opts "$host" "uptime" >> "$TMP_DIR/$host.uptime" 2> "$TMP_DIR/$host.ssh_error"; then
                 echo "Error SSH (uptime): $(cat "$TMP_DIR/$host.ssh_error")" > "$TMP_DIR/$host.uptime"
             fi

        else
            echo "Host: $host - ESTADO: INACTIVO o NO RESPONDE" > "$TMP_DIR/$host.status"
             echo "--- Usuarios Conectados ---" > "$TMP_DIR/$host.users"
             echo "(Host inactivo)" >> "$TMP_DIR/$host.users"
             echo "--- Uptime ---" > "$TMP_DIR/$host.uptime"
             echo "(Host inactivo)" >> "$TMP_DIR/$host.uptime"
        fi
         echo "Verificación completada para: $host"

    ) &
    pids+=($!)

done

echo "Esperando a que terminen todas las verificaciones..."
wait

echo "Recolectando resultados..."

for host in "${HOSTS[@]}"; do
    cat "$TMP_DIR/$host.status" >> "$OUTPUT_FILE"
    cat "$TMP_DIR/$host.users" >> "$OUTPUT_FILE"
    cat "$TMP_DIR/$host.uptime" >> "$OUTPUT_FILE"
    echo "-------------------------------------" >> "$OUTPUT_FILE"
done

rm -rf "$TMP_DIR"

echo "Verificación completa. Resultados en $OUTPUT_FILE"
exit 0