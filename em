#!/usr/bin/perl
#==============================================================================#
# POD                                                                          #
#==============================================================================#
# {{{
=pod

=head1 NAME

em - console emphasis tool version 2

=head1 DESCRIPTION

em is a command line tool for visually emphasizing text in log files etc. by
colorizing the output matching regular expressions.
 
=head1 SYNOPSIS

em FILE   | em <stdin

=head1 USAGE

REGEX is any regular expression recognized by Perl. For some shells this must be
enclosed in double quotes ("") to prevent the shell from interpolating special
characters like * or ?.

COLOR is any ANSI color string accepted by Term::ANSIColor, such as
'green' or 'bold red'.

Any number of REGEX-COLOR pairs may be specified. If the number of arg
+uments
is odd (i.e. no COLOR is specified for the last REGEX) em will use 'bo
+ld yellow'.

Overlapping rules are supported. For characters that match multiple rules, 
only the last rule will be applied.

=head1 EXAMPLES

In a system log, emphasize the words "error" and "ok":

=over

tail -f /var/log/messages | em error red ok green

=back

In a mail server log, show all email addresses between <> in white, su
+ccesses in green:

=over

tail -f /var/log/maillog | em "(?<=\<)[\w\-\.]+?\@[\w\-\.]+?(?=\>)" "b
+old white" "stored message|delivered ok" "bold green"

=back

In a web server log, show all URIs in yellow:

=over

tail -f /var/log/httpd/access_log | em "(?<=\"get).+?\s"

=back

=head1 BUGS AND LIMITATIONS

Multi-line matching is not implemented.

All regular expressions are matched without case sensitivity.

=head1 AUTHOR

Andreas Lund <floyd@atc.no>

=head1 SEE ALSO

B<h>

=head1 COPYRIGHT AND LICENSE

Copyright 2009-2013 Andreas Lund <floyd@atc.no>. This program is free 
+software; 
you may redistribute it and/or modify it under the same terms as Perl 
+itself.

=cut

# }}}
#==============================================================================#
# ENVIRONMENT                                                                  #
#==============================================================================#
# {{{
# Entorno
$|++;
use strict;
use warnings;
use Term::ANSIColor;

# }}}
# {{{
# Variables --------------------------------------------------------------------
my %rules;

# }}}
# {{{
# Read config ------------------------------------------------------------------
while (<DATA>){
    chomp;
    next if /^$/;
    next if /^\s*#/;
    my ($a,$b) = split /:/,$_,2;
    $rules{$b}=$a;
}
# }}}
#==============================================================================#
# MAIN                                                                         #
#==============================================================================#
# {{{
while (my $line = <>) {
  print rewrite($line);
}
exit;
# }}}
#==============================================================================#
# FUNCTIONS                                                                    #
#==============================================================================#
# {{{
sub rewrite {
    # Process a single line
    my $line = shift;
    my @marks = ();
    # Process each rule and find areas to mark
    foreach (keys %rules) {
        my $regex = $_;
        my $color = $rules{$_}|| 'bold yellow';
        $color = color('reset').color($color);
        while ($line =~ /$regex/ig) {
            my $reset = undef;
            # Scan match area to find last color
            foreach my $i (reverse $-[0] .. $+[0]) {
                if (defined $marks[$i]) {
                    $reset = $marks[$i] unless defined $reset; 
                    $marks[$i] = undef; # Cancel previous color
                }
            }
            # If necessary, keep scanning to beginning of line
            unless (defined $reset) {
                foreach my $i (reverse 0 .. $-[0]) {
                    if (defined $marks[$i]) {
                        $reset = $marks[$i]; 
                        last;
                    }
                }
            }
            # Mark area
            $marks[$-[0]] = $color;
            $marks[$+[0]] = $reset || color('reset');
        }    
    }
    # Apply color codes to the string
    foreach my $i (reverse 0 .. $#marks) {
        substr($line, $i, 0, $marks[$i]) if defined $marks[$i];
    }
    return $line;
}
# }}}
#==============================================================================#
# DATA                                                                         #
#==============================================================================#
# {{{
__DATA__
# Good words
green:(\w*activ\w*|start\w*|\bready\b|online|\w*load\w*|\bok\b|register\w*|detect\w*|configured|enable\w*|listen\w*|open\w*|complete|attempt\w*|done|check)

# Warning words
yellow:(warn\w*|restart\w*|exit\w*|stop\w*|\bend\b|shutting|\bdown\b|close\w*|unreach\w*|can't|cannot|skip|deny|disable\w*|ignor\w*|miss\w*|oops|\bsu\b|\bnot\b|backdoor|blocking|unable|readonly|offline|\bbad\b)

# Errors
red:(error|crit\w*|invalid|fail\w*|false)

# system
white:(ext\d-fs|reiserfs|vfs|\biso\b|\bisofs\b|cslip|\beth\d\b|\bppp\b|\bbsd\b|linux|\bip\b|\btcp\/ip\b|mtrr|\bpci\b|\bisa\b|scsi|\bide\b|atapi|\bbios\b|\bcpu\b|\bfpu\b)

# Fechas
green:\d{4}-\d\d-\d\d\s\d\d:\d\d:\d\d

#IP:port
cyan:(\d{1,3}\.){3}\d{1,3}(:\d{1,5})?[^\/]
cyan:ip-(\d{1,3}-){3}\d{1,3}(:\d{1,5})?[^\/]

# Network
green:(\d{1,3}\.){3}\d{1,3}/\d\d?\b

#email
magenta:<?[\w\.\-_]+@[\w\.\-_]+>?
