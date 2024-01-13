#!/usr/bin/perl
#==============================================================================#
# POD                                                                          #
#==============================================================================#
# {{{
=encoding utf-8

=head1 NAME

B<f> - Imprime una o varias columnas de la entrada

=head1 SYNOPSIS

=over 4

=item f [-h|--help|-u|-V|--version]

=item f [-v] [-s SEP] [-i FILE]  col [col...]

=back

=head1 DESCRIPTION

Permite extraer varias columnas de la entrada estándar.

=head1 OPTIONS

=over 4

=item B<-h>

Muestra la información de ayuda completa.

=item B<-i> FILE

Se lee el fichero indicado, en vez de la entrada estándar.

=item B<-s> SEP (string)

Separador alternativo.

DEFAULT: ' '

=item B<-u>

Muestra la información básica de uso (SYNOPSIS).

=item B<-v>

Muestra información detallada durante la ejecución.

=item B<-V>

Muestra la versión del comando y los módulos usados.

=back

=head1 SAMPLES

ls -l|f 2 1 3

f -i A_CSV_FILE.CSV -s \; 2 1 3

=head1 BUGS

No hay fallos conocidos en este script. Por favor informe de cualquier
fallo al autor.

Parches para mejoras o errores, comentarios y sugerencias serán
bienvenidos.

=head1 COPYRIGHT & LICENSE

Copyright 2013 el autor.

Todos los derechos reservados.

Puede usar, copiar, modificar, distribuir y vender este software, reconociendo
a su autor original y de acuerdo con los términos de la licencia GPL. (GNU
General Public License).

I<No se dan garantías de ningun tipo. Use este software a su propio riesgo.>

=head1 AUTHOR

Luís M. Arocha Hernández <lah.data@gmail.com>

=cut
# }}}
#==============================================================================#
# ENVIRONMENT                                                                  #
#==============================================================================#
# {{{ Modulos y pragmas
use strict;
use CommonFunc qw/:all/;
use Getopt::Std;

# }}}
# {{{ Constantes (o casi)
our $VERSION = substr q$Revision: 3.1 $, 10;

# }}}
# {{{ Variables
my @F;
my %opt;
my @c;

# }}}
# {{{ Parametros
getopts( 'hi:s:uvV', \%opt ) or usage('Fallo parámetros');
help()              if $opt{h};
usage()             if $opt{u};
if ($opt{V}){version();exit 1;}
warn "Args=@ARGV\n" if $opt{v};
@c = @ARGV;
@ARGV = qw//;
unshift @ARGV,$opt{i} if $opt{i};

# }}}
#==============================================================================#
# MAIN                                                                         #
#==============================================================================#
# {{{
# Procesar entrada
while (<>) {
    chomp;
    if ($opt{s}){
        @F = split $opt{s};
    } else {
        @F = split;
    }
    foreach (@c) {
        print $F[$_ - 1] . ' ';
    }
    print "\n";
}
exit 0;
# }}}
