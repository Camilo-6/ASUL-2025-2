#!/bin/bash

# Archivo que contiene la lista de nombres de host
lista_hosts="revisar.csv"
usuario_ssh="yankees"
espera=10

# Crear archivo de registro con fecha y hora actual
fecha_hora=$(date +"%Y%m%d_%H%M%S")
registro="resultado_chequeo_$fecha_hora.txt"

echo "Comienzo del chequeo de sistemas - $fecha_hora" | tee "$registro"
echo "==============================================" | tee -a "$registro"

# Leer hosts desde el archivo y recorrer cada uno
while IFS= read -r equipo || [[ -n "$equipo" ]]; do
    equipo=$(echo "$equipo" | xargs)  # eliminar espacios alrededor
    [[ -z "$equipo" ]] && continue    # omitir líneas vacías

    echo "Verificando disponibilidad de '$equipo' como '$usuario_ssh'..." | tee -a "$registro"

    ssh -o ConnectTimeout=$espera \
        -o BatchMode=yes \
        -o PasswordAuthentication=no \
        "$usuario_ssh@$equipo" \
        "echo 'Usuarios activos:'; who; echo 'Sistema activo desde:'; uptime -p" > temp_salida.log 2>&1

    estado=$?

    if [[ $estado -eq 0 ]]; then
        echo "Acceso correcto a $equipo" | tee -a "$registro"
        cat temp_salida.log | tee -a "$registro"
    else
        mensaje_error="Fallo al conectar con $usuario_ssh@$equipo"

        grep -q "timed out" temp_salida.log && mensaje_error="$mensaje_error (tiempo excedido)"
        grep -q "No route to host" temp_salida.log && mensaje_error="$mensaje_error (host inalcanzable)"
        grep -q "Connection refused" temp_salida.log && mensaje_error="$mensaje_error (rechazado)"
        grep -q "Permission denied" temp_salida.log && mensaje_error="$mensaje_error (acceso denegado)"

        echo "$mensaje_error" | tee -a "$registro"
    fi

    echo "----------------------------------------------" | tee -a "$registro"
done < "$lista_hosts"

echo "Chequeo completado - $(date +'%Y-%m-%d %H:%M:%S')" | tee -a "$registro"
