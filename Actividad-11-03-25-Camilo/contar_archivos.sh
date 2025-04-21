#!/bin/bash

# Verifica si se paso un argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <directorio>"
    exit 1
fi

# Verifica si el argumento es un directorio valido
if [ ! -d "$1" ]; then
    echo "Error: '$1' no es un directorio valido o no existe"
    exit 1
fi

# Cuenta los tipos de archivos en el directorio dado
info=$(ls -l "$1" | cut -c1 | sort | uniq -c)

# Mostrar la informacion diciendo que tipo de archivo es, ejemplo "-" es un archivo regular, "d" es un directorio, etc.
echo "$info" | while read line; do
    count=$(echo $line | awk '{print $1}')
    type=$(echo $line | awk '{print $2}')
    case $type in
        "-") echo "Archivos regulares: $count";;
        "d") echo "Directorios: $count";;
        "c") echo "Dispositivos de caracteres: $count";;
        "b") echo "Dispositivos de bloques: $count";;
        "l") echo "Enlaces simbolicos: $count";;
        "s") echo "Sockets: $count";;
        "p") echo "Pipes: $count";;
    esac
done
