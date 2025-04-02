#!/bin/bash

# Verificar que se pase al menos un argumento
if [ $# -eq 0 ]; then
    echo "Uso: $0 \"usuario1,usuario2,usuario3,...\""
    exit 1
fi

# Convertir la cadena en una lista sin duplicados
IFS=',' read -r -a usuarios <<< "$(echo "$1" | tr ',' '\n' | sort -u | tr '\n' ',')"

echo "Procesando usuarios..."

# Verificar que el comando mkpasswd.pl este disponible
if ! command -v mkpasswd.pl &>/dev/null; then
    echo "Error: mkpasswd.pl no encontrado. Instálalo con: apt install whois"
    exit 1
fi

# Crear usuarios si no existen y generar contrasenias
declare -A credenciales

for usuario in "${usuarios[@]}"; do
    # Verificar si el usuario ya existe
    if id "$usuario" &>/dev/null; then
        echo "El usuario $usuario ya existe, se omite la creacion"
    else
        # Generar contrasenia segura
        contrasenia=$(mkpasswd.pl -l 10 -c 3 -C 3 -s 2 -n 2 2>/dev/null | head -n 1)
        
        # Crear el usuario con la contrasenia generada
        useradd -m -s /bin/bash "$usuario"
        echo "$usuario:$contrasenia" | chpasswd

        # Guardar credenciales
        credenciales["$usuario"]="$contrasenia"

        echo "Usuario $usuario creado"
    fi
done

# Crear el grupo debian si no existe
if ! getent group debian &>/dev/null; then
    groupadd debian
    echo "Grupo debian creado"
else
    echo "El grupo debian ya existe"
fi

# Agregar usuarios al grupo debian
for usuario in "${usuarios[@]}"; do
    usermod -aG debian "$usuario"
done

# Mostrar usuarios y sus contrasenias
echo -e "\nUsuarios creados y sus contrasenias:"
for usuario in "${!credenciales[@]}"; do
    echo "$usuario: ${credenciales[$usuario]}"
done

# arturo,asahel,dulce,arsenio,sara,yankees,carlos_trejo,jaime_maussan,alfredo_adame,asulito,lexyrey,corrupter,apb,msr,hola,rafa,maw,fernando,javiermq,uriel,eduardo,miguel,fernando,andrea,yankees,carlos_trejo,jaime_maussan,alfredo_adame,ethan,felix,debian1