#!/usr/bin/perl
# Ejecutar con: perl intento.pl
# Fuente: https://perldoc.perl.org/
# Version usada perl v5.38.3

use strict;
use warnings;

# Variable y ciclo
my $name = "Camilo";
for my $i (1..3) {
    print "Hola, $name! Intento $i\n";
}

# Condicional
if ($name eq "Camilo") {
    print "¡Hola, $name!\n";
} else {
    print "¡Hola, desconocido!\n";
}

# Funcion
sub saludar {
    my ($nombre) = @_;
    print "¡Hola, $nombre!\n";
}
saludar("Perl");

# Clases y objetos
package Persona;
sub new {
    my $class = shift;
    my $self = { nombre => shift };
    bless $self, $class;
    return $self;
}
sub saludar {
    my $self = shift;
    print "¡Hola, soy $self->{nombre}!\n";
}
my $persona = Persona->new("Camilo");
$persona->saludar();

# String
my $nombre = "Camilo";

# Numeros
my $edad = 21;

# Booleanos (Perl usa 0, undef, "" como false; cualquier otro valor es true)
my $es_estudiante = 1;

print "Nombre: $nombre, Edad: $edad, ¿Estudiante?: $es_estudiante\n";

# Arreglo
my @frutas = ("manzana", "pera", "uva");
print "Primera fruta: $frutas[0]\n";

# Hash (diccionario)
my %persona = (
    nombre => "Camilo",
    edad => 21
);
print "Nombre: $persona{nombre}, Edad: $persona{edad}\n";

# Uso de bibliotecas (modulos)
use Time::Piece;

my $time = localtime;
print "Fecha actual: $time\n";

# Tipado dinamico
my $variable = "Hola";
print "Variable: $variable\n";
$variable = 42;
print "Variable: $variable\n";

# Debilmente tipado
my $numero = "21";
my $suma = $numero + 21;
print "Suma: $suma\n";

# Expresiones regulares
sub es_numero {
    $numero = shift; # Obtener el primer parametro
    if ($numero =~ /^[0-9]+$/)
    {
        print "$numero es un numero\n";
    }
    else
    {
        print "$numero no es un numero\n";
    }
}
es_numero("42");
es_numero("hola");

