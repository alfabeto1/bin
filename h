#!/bin/bash
#==============================================================================#
# POD                                                                          #
#==============================================================================#
# {{{
NUL=<<=cut
=head1 NAME

B<h> - highlights with color specified keywords when you invoke it via pipe

=head1 DESCRIPTION:

h is just a tiny wrapper around the powerful 'ack' (or 'ack-grep'). you
need 'ack' installed to use h.

=head1 OPTIONS

-i : ignore case

-d : disable regexp

-n : invert colors

=head1 EXAMPLE

try to invoke:

    echo "abcdefghijklmnopqrstuvxywz" | h   a b c d e f g h i j k l

=head1 CONFIGURATION

* you can alter the color and style of the highlighted tokens setting values
to these 2 environment values following "Perl's Term::ANSIColor" supported
syntax

* ex.

    export H_COLORS_FG="bold black on_rgb520","bold red on_rgb025"
    export H_COLORS_BG="underline bold rgb520","underline bold rgb025"
    echo abcdefghi | h   a b c d

=head1 SEE ALSO

B<em>, B<grcat>

* https://github.com/paoloantinori/hhighlighter

* ack website: http://beyondgrep.com/

* man ack

=cut

# }}}
#==============================================================================#
# FUNCTIONS                                                                    #
#==============================================================================#
# {{{
_usage() {
    echo "usage: YOUR_COMMAND | h [-idn] args...
-i : ignore case
-d : disable regexp
-n : invert colors"
}
# }}}
#==============================================================================#
# ENVIRONMENT                                                                  #
#==============================================================================#
# {{{
# Variables
_i=0
# }}}
# {{{
# detect pipe or tty
if [[ -t 0 ]]; then
    _usage
    exit 1
fi

# }}}
# {{{
# Parametros
while getopts ":idnQ" opt; do
    case $opt in
        i) _OPTS+=" -i " ;;
        d)  _OPTS+=" -Q " ;;
        n) n_flag=true ;;
        Q)  _OPTS+=" -Q " ;;
            # let's keep hidden compatibility with -Q for original ack users
        \?) _usage
            exit 1;;
    esac
done

shift $(($OPTIND - 1))
# }}}
#==============================================================================#
# MAIN                                                                         #
#==============================================================================#
# {{{
# set zsh compatibility
[[ -n $ZSH_VERSION ]] && setopt localoptions && setopt ksharrays && setopt ignorebraces

# }}}
# {{{
# Do it

if [[ -n $H_COLORS_FG ]]; then
    _CSV="$H_COLORS_FG"
    OLD_IFS="$IFS"
    IFS=','
    _COLORS_FG=()
    for entry in $_CSV; do
        _COLORS_FG=("${_COLORS_FG[@]}" "$entry")
    done
    IFS="$OLD_IFS"
else
    _COLORS_FG=( 
            "underline bold red" \
            "underline bold green" \
            "underline bold yellow" \
            "underline bold blue" \
            "underline bold magenta" \
            "underline bold cyan"
            )
fi

if [[ -n $H_COLORS_BG ]]; then
    _CSV="$H_COLORS_BG"
    OLD_IFS="$IFS"
    IFS=','
    _COLORS_BG=()
    for entry in $_CSV; do
        _COLORS_BG=("${_COLORS_BG[@]}" "$entry")
    done
    IFS="$OLD_IFS"
else
    _COLORS_BG=(            
            "bold on_red" \
            "bold on_green" \
            "bold black on_yellow" \
            "bold on_blue" \
            "bold on_magenta" \
            "bold on_cyan" \
            "bold black on_white"
            )
fi

if [[ -z $n_flag ]]; then
    #inverted-colors-last scheme
    _COLORS=("${_COLORS_FG[@]}" "${_COLORS_BG[@]}")
else
    #inverted-colors-first scheme
    _COLORS=("${_COLORS_BG[@]}" "${_COLORS_FG[@]}")
fi

if [[ "$#" -gt ${#_COLORS[@]} ]]; then
    echo "
    You have passed to h highlighter more keywords to search than the number of
    configured colors. Check the content of your H_COLORS_FG and H_COLORS_BG
    environment variables or unset them to use default 12 defined colors."
    exit 1
fi

if [ -n "$ZSH_VERSION" ]; then
    WHICH="whence"
else [ -n "$BASH_VERSION" ]
    WHICH="type -P"
fi
ACK=ack

# build the filtering command
for keyword in "$@"
do
    _COMMAND=$_COMMAND"$ACK $_OPTS --noenv --flush --passthru --color --color-match=\"${_COLORS[$_i]}\" '$keyword' |"
    _i=$_i+1
done
#trim ending pipe
_COMMAND=${_COMMAND%?}
cat - | eval $_COMMAND
# }}}
