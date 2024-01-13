#!/bin/sh
### Envia un comando a mldonkey
# Luís M. Arocha Hernández
if [ ! -d /pub/mldonkey ]; then
    echo Fail. No mldonkey here.
    exit 1
fi
/bin/nc -q 2 localhost 4000 <<EOF
auth luis $MLPASS
$@
q
EOF
