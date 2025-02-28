#!/bin/zsh
# Ejecutar con: zsh intento.zsh
# Fuente: https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html
# Fuente: https://zsh-manual.netlify.app/the-z-shell-manual
# Version usada zsh 5.9

# Variable y ciclo while
contador=1
while [ $contador -le 3 ]; do
    echo "Intento $contador"
    ((contador++))
done

# Condicional
if [[ $contador -gt 3 ]]; then
    echo "¡Terminamos!"
fi

# Funcion
function despedir() {
    echo "Adios desde Zsh!"
}
despedir

# Strings y numeros
name="Camilo"
age=21

# Booleanos simulados
is_student=true

echo "Nombre: $name, Edad: $age, ¿Estudiante?: $is_student"

# Arreglo
frutas=("manzana" "pera" "uva")
echo "Frutas: $frutas[1]" # Zsh usa indices desde 1

# Arreglo asociativo (diccionario)
typeset -A persona
persona[nombre]="Camilo"
persona[edad]=21
echo "Nombre: ${persona[nombre]}, Edad: ${persona[edad]}"

# Usar el comando date como "biblioteca"
fecha=$(date)
echo "Hoy es: $fecha"

# Clases (usando arreglos asociativos para simular)
typeset -A animal
animal[nombre]="Tigre"
animal[edad]=5
animal[raza]="Felino"
echo "Nombre: ${animal[nombre]}, Edad: ${animal[edad]}, Raza: ${animal[raza]}"

# Tipado dinamico
variable="Hola"
echo "Variable: $variable"
variable=5
echo "Variable: $variable"

# Debilmente tipado
numero="5"
suma=$((numero + 5)) # se necesitan los parentesis para operaciones aritmeticas
echo "Suma: $suma"

# Expresiones regulares
function es_numero() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        echo "$1 es un numero"
    else
        echo "$1 no es un numero"
    fi
}
es_numero "5"
es_numero "hola"

