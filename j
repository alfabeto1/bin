#!/bin/bash
#==============================================================================#
# POD                                                                          #
#==============================================================================#
# {{{
NUL=<<=cut
=encoding utf-8

=head1 NAME

B<j> - Edita y/o crea fichero de journal

=head1 SYNOPSIS

=over 4

=item B<j> [-h|-u|-V]

=item B<j> [-v] [-l|-r]

=item B<j> [-y]

=item B<j> [regexp]

=back

=head1 DESCRIPTION

Edita y/o crea fichero de journal.

Si no se dan opciones ni argumento edita el del día.

=head1 OPTIONS

=over 4

=item B<-h>

Muestra la información de ayuda completa.

=item B<-l>

Lista con vim los ficheros de la carpeta de journal para edición.

=item B<-u>

Muestra la información básica de uso (SYNOPSIS).

=item B<-v>

Muestra información detallada durante la ejecución.

=item B<-V>

Muestra la versión del comando.

=item B<-y>

Yesterday. Se edita el ultimo fichero.

=back

=head1 ARGUMENTS

Si se indica un argumento despues de las opciones, se editan todos los ficheros
de journal que tengan ese argumento en el nombre: Journal-*ARG*.md.

Si no se indica argumento edita el fichero del día de hoy.

=head1 FILES

Los ficheros de journal se crean en el directorio
F<$HOME/Dropbox/NOTAS/Journal>. Debe existir.

=head1 BUGS

No hay fallos conocidos en este script. Por favor informe de cualquier
fallo al autor.

Parches para mejoras o errores, comentarios y sugerencias serán
bienvenidos.

=head1 COPYRIGHT & LICENSE

Copyright 2015 el autor.

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
# FUNCTIONS                                                                    #
#==============================================================================#
# {{{
function usage {
    if test "$*"; then
        echo $*
    fi
    pod2usage -verbose 1 $0
    exit 1
}

# }}}
# {{{
function help {
    pod2text -c $0
    exit 1
}

# }}}
#==============================================================================#
# ENVIRONMENT                                                                  #
#==============================================================================#
# {{{ Variables
VERSION="$Revision: 3.1 $"
VERSION=${VERSION#:\ }
VERSION=${VERSION%\ \$}
today=1
yesterday=0
DIR=$HOME/Dropbox/NOTAS/Journal
d=`date +%Y-%m-%d`
f=Journal-$d.md

# }}}
# {{{ Parametros
while getopts ahlryuvV options; do
    case "$options" in
        a) all=1;;
        h) help ;;
        l) today=0 ;;
        u) usage ;;
        v) verbose=on ;;
        V) echo "${0/*\//} - $VERSION";exit 1;;
        y) today=0;yesterday=1;;
       \?) usage "Fallo parámetros" ; exit 1 ;;
    esac
done
shift $(( $OPTIND - 1 ))
if [ "$1" != "" ]; then today=0 ; fi

# }}}
#==============================================================================#
# MAIN                                                                         #
#==============================================================================#
# {{{ check
if [ ! -d $DIR ] ; then
    echo Maquina incorrecta o falta carpeta
    exit 1
fi
# }}}
# {{{ edit all
cd $DIR
if [ "$all" == "1" ]; then
    files=`dir -r -1 *.md|head`
    vim $files
    exit 0
fi
# }}}
# {{{ today or yesterday or wildcard
if [ "$today" == "1" ] ; then
    last=`dir -1 *.md|tail -1`
    if [ "$last" != "$f" ] ; then
        echo Recuperado último: $last
        perl -ne 'print; exit 0 if /Completado/' $last >>$f
    fi
    vim $f
    test $verbose && echo Editado $f
else
    if [ "$yesterday" == "1" ] ; then
        last=`dir -1 *.md|tail -1`
        vim $last
    else
        if [ "$1" ] ; then
            v $1
        else
            vim .
        fi
    fi
fi
# }}}
# {{{ End
# make
cd - >/dev/null
exit 0

# }}}
