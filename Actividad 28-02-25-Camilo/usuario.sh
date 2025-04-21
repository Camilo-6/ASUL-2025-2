#!/bin/bash

# Verificar si cpanminus esta instalado
if ! command -v cpanm &>/dev/null; then
    echo "cpanminus no esta instalado. Verificando si cpan esta disponible..."
    
    # Verificar si cpan esta instalado
    if ! command -v cpan &>/dev/null; then
        echo "Instalando cpan..."
        sudo dnf install -y perl-CPAN
    fi

    # Instalar cpanminus
    echo "Instalando cpanminus..."
    yes | sudo cpan App::cpanminus
fi

# Verificar si LWP::Protocol::https esta instalado
if ! perl -MLWP::Protocol::https -e 1 2>/dev/null; then
    echo "Instalando LWP::Protocol::https..."
    sudo cpanm LWP::Protocol::https
fi

# Instalar el modulo String::MkPasswd si no esta presente
if ! perl -MString::MkPasswd -e 1 2>/dev/null; then
    echo "Instalando el modulo String::MkPasswd..."
    sudo cpanm String::MkPasswd
fi

# Verificar si el modulo se instalo correctamente
if ! perl -MString::MkPasswd -e 1 2>/dev/null; then
    echo "Error: No se pudo instalar String::MkPasswd."
    exit 1
fi

# Limpiar la pantalla
clear

# Pedir el nombre completo
echo "Introduce tu nombre completo, separando el nombre y los apellidos por comas."
echo "Ejemplo: Jose Camilo, Garcia, Ponce"
read -p "" nombre_completo

# Verificar si el nombre completo esta vacio
if [ -z "$nombre_completo" ]; then
    echo "Error: El nombre completo no puede estar vacio."
    exit 1
fi

# Partir el nombre completo
IFS=',' read -r -a partes <<< "$nombre_completo"
# Partir el nombre
IFS=' ' read -r -a nombre <<< "${partes[0]}"
# Poner todo en minusculas
nombre[0]=$(echo ${nombre[0]} | tr '[:upper:]' '[:lower:]')
nombre[1]=$(echo ${nombre[1]} | tr '[:upper:]' '[:lower:]')
partes[1]=$(echo ${partes[1]} | tr '[:upper:]' '[:lower:]')
partes[2]=$(echo ${partes[2]} | tr '[:upper:]' '[:lower:]')

# Generar el usuario
usuario=$(echo ${nombre[0]} | cut -c 1)$(echo ${nombre[1]} | cut -c 1)$(echo ${partes[1]})$(echo ${partes[2]} | cut -c 1)

# Generar la contrasena
contrasenia=$(mkpasswd.pl -l 10 -c 3 -C 3 -s 2 -n 2 2>/dev/null)

# Verificar si el usuario ya existe
if id "$usuario" &>/dev/null; then
    echo "El usuario $usuario ya existe."
else
    # Crear el usuario en el sistema con la contrasenia generada
    sudo useradd -m -s /bin/bash "$usuario"
    echo "$usuario:$contrasenia" | sudo chpasswd
    echo "Usuario creado: $usuario"
    echo "Contrasenia: $contrasenia"
fi
