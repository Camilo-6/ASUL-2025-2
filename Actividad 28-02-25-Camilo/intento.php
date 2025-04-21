<?php
// Ejecutar con: php intento.php
// Fuente: https://www.php.net/manual/en/
// Version usada php 8.3.17

// Variable y ciclo
$name = "Camilo";
for ($i = 1; $i <= 3; $i++) {
    echo "Hola, $name! Intento $i\n";
}

// Condicional
$age = 21;
if ($age >= 18) {
    echo "Eres mayor de edad\n";
} else {
    echo "Eres menor de edad\n";
}

// Funcion
function saludar($nombre) {
    echo "¡Hola, $nombre!\n";
}
saludar("PHP");

// Clase y objeto
class Persona {
    public $nombre;
    function __construct($nombre) {
        $this->nombre = $nombre;
    }
    function saludar() {
        echo "¡Hola, soy $this->nombre!\n";
    }
}
$persona = new Persona("Camilo");
$persona->saludar();

// String
$name = "Camilo";

// Numero
$age = 21;

// Booleano
$isStudent = true;

echo "Nombre: $name, Edad: $age, ¿Estudiante?: " . ($isStudent ? "Si" : "No") . "\n";

// Arreglo
$frutas = ["manzana", "pera", "uva"];
echo "Primera fruta: {$frutas[0]}\n";

// Diccionario
$persona = [
    "nombre" => "Camilo",
    "edad" => 21
];
echo "Nombre: {$persona['nombre']}, Edad: {$persona['edad']}\n";

// Usar una funcion integrada
echo "Fecha actual: " . date("Y-m-d H:i:s") . "\n";

// Usar una biblioteca
use DateTime;
$fecha = new DateTime();
echo "Fecha con objeto: " . $fecha->format('Y-m-d H:i:s') . "\n";

// Tipado dinamico
$variable = "Hola";
echo "Variable: $variable\n";
$variable = 3;
echo "Variable: $variable\n";

// Debilmente tipado
$numero = "5";
$suma = $numero + 3;
echo "Suma: $suma\n";

// Puede ser fuertemente tipado
// declare(strict_types=1); // con esto al inicio del archivo

// Expresiones regulares
function es_numero($numero) {
    if (preg_match('/^[0-9]+$/', $numero)) {
        echo "$numero es un numero\n";
    } else {
        echo "$numero no es un numero\n";
    }
}
es_numero("5");
es_numero("cinco");
?>
