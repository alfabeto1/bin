#!/bin/bash
### Edita ficheros en directorio actual que coincidan con nombre dado
# Luís M. Arocha Hernández
if [ "$1" == "" ]; then
    echo Edita ficheros en directorio actual que coincidan con regexp
    echo Usage: v regexp
    exit
fi
LIST=`find -type f|\
    grep -i $1|grep -v ~$|\
    grep -v CVS|grep -v "jpg$" |\
    grep -v '\.html$'|\
    grep -v '\.htm$'|\
    grep -v '\.pdf$'|\
    grep -vi "/$1/"|sort`
if [ "$LIST" = "" ]; then
    echo "No files"
else
    if ! [ -f "$LIST" ]; then
        echo $LIST
        echo -n '=>'
        read
    fi
    vim -o1 $LIST
fi


