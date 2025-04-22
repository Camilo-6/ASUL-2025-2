#!/bin/bash

# Parte de las direcciones IPs
archivo="hosts.csv"

# Funcion para agregar entradas a /etc/hosts
agregar_a_hosts() {
    ip="$1"
    host="$2"
    
    # Comprobar si la entrada ya existe en /etc/hosts
    if ! grep -q "$ip" /etc/hosts; then
        # Agregar la entrada al archivo /etc/hosts
        echo "$ip $host" | sudo tee -a /etc/hosts > /dev/null
        echo "Se agrego la entrada: $ip $host a /etc/hosts"
    else
        echo "La entrada para $ip ya existe en /etc/hosts"
    fi
}

# Leer el archivo CSV
while IFS=, read -r host ip ipv6; do
    # Llamar a la funcion para agregar la entrada al archivo /etc/hosts
    agregar_a_hosts "$ip" "$host"
done < "$archivo"


# Parte de las llaves publicas
archivo="claves.csv"
contador=0

# Leer el archivo linea por linea
while IFS= read -r linea || [[ -n "$linea" ]]; do
    contador=$((contador + 1))

    # Ignorar lineas vacias
    [[ -z "$linea" ]] && echo "[$contador] Linea vacia, se omite" && continue

    # Obtener tipo, clave y comentario
    tipo=$(echo "$linea" | awk '{print $1}')
    clave=$(echo "$linea" | awk '{print $2}')
    comentario=$(echo "$linea" | cut -d' ' -f3-)

    # Validar que tipo, clave y comentario no esten vacios
    if [[ -z "$tipo" || -z "$clave" || -z "$comentario" ]]; then
        echo "[$contador] Clave malformada, se omite: $linea"
        continue
    fi

    # Validar que la informacion de la clave sea correcta
    if [[ "$comentario" == *"@"* ]]; then
        usuario=$(echo "$comentario" | cut -d'@' -f1)
        host=$(echo "$comentario" | cut -d'@' -f2)
        echo "[$contador] ✓ Tipo: $tipo | Usuario: $usuario | Host: $host"

        # Verificar si el usuario ya existe
        if ! id "$usuario" &>/dev/null; then
            # Crear el usuario
            useradd -m -s /bin/bash "$usuario"
            if [[ $? -ne 0 ]]; then
                echo "[$contador] ✗ Error al crear el usuario $usuario"
                continue
            fi
            echo "[$contador] Usuario $usuario creado"
        else
            echo "[$contador] El usuario $usuario ya existe, se omite la creacion"
        fi

        # Preparar directorio .ssh y archivo authorized_keys
        ssh_dir="/home/$usuario/.ssh"
        auth_file="$ssh_dir/authorized_keys"
        mkdir -p "$ssh_dir"
        chmod 700 "$ssh_dir"
        touch "$auth_file"
        chmod 600 "$auth_file"
        chown -R "$usuario:$usuario" "$ssh_dir"

        # Linea completa de la clave
        linea_completa="$tipo $clave $comentario"

        # Verificar si la clave ya existe en el archivo authorized_keys
        if ! grep -qxF "$linea_completa" "$auth_file"; then
            # Agregar la clave al archivo authorized_keys
            echo "$linea_completa" >> "$auth_file"
            echo "[$contador] Clave agregada a $usuario"
        else
            echo "[$contador] La clave ya existe en $usuario, se omite"
        fi
    else
        echo "[$contador] ✗ Comentario no contiene '@', se omite: $comentario"
        continue
    fi

done < "$archivo"