#!/bin/bash
# Ejecutar con: chmod +x intento.sh && ./intento.sh
# Fuente http://gnu.org/savannah-checkouts/gnu/bash/manual/bash.html
# Fuente https://tldp.org/LDP/abs/html/
# Version usada bash 5.2.26(1)-release

# Variable y ciclo for
name="Camilo"
for i in {1..3}; do
    echo "Hola, $name! Intento $i"
done

# Condicional if
if [ "$name" == "Camilo" ]; then
    echo "¡Eres tu!"
else
    echo "¿Quien eres?"
fi

# Funcion
saludar() {
    echo "¡Hola desde una funcion en Bash!"
}
saludar

# Strings
name="Camilo"

# Numeros
age=21

# Booleanos (no existen directamente, se simulan con 0 y 1 o true/false strings)
is_student=true

echo "Nombre: $name, Edad: $age, ¿Estudiante?: $is_student"

# Arreglo
frutas=("manzana" "pera" "uva")
echo "Primera fruta: ${frutas[0]}"

# Arreglo asociativo (diccionario)
declare -A persona
persona[nombre]="Camilo"
persona[edad]=21
echo "Nombre: ${persona[nombre]}, Edad: ${persona[edad]}"

# Usar el comando date como "biblioteca"
fecha=$(date)
echo "La fecha actual es: $fecha"

# Clases (usando arreglos asociativos para simular)
declare -A animal
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
es_numero() {
    if [[ $1 =~ ^[0-9]+$ ]]; then
        echo "$1 es un numero"
    else
        echo "$1 no es un numero"
    fi
}
es_numero "5"
es_numero "hola"

