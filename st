#!/usr/bin/perl
#==============================================================================#
# POD                                                                          #
#==============================================================================#
# {{{
=encoding utf-8

=head1 NAME

B<st> - Abre un fichero con el programa apropiado

=head1 SYNOPSIS

=over 4

=item st [-h|--help|-u|-V|--version]

=item st [-v] [-d] F<FILE...>

=back

=head1 DESCRIPTION

Dependiendo del tipo de fichero de entrada ejecutara la aplicación
correspondiente.

=head1 ARGUMENTS

Como argumentos se aceptan uno o más ficheros.

=head1 OPTIONS

=over 4

=item B<-d>

Una vez visualizado el documento se pregunta si se desea borrar.

=item B<-h>, B<--help>

Muestra la información de ayuda completa.

=item B<-u>

Muestra la información básica de uso (SYNOPSIS).

=item B<-v>

Muestra información detallada durante la ejecución.

=item B<-V>, B<--version>

Muestra la versión del comando y los módulos usados.

=back

=head1 COPYRIGHT & LICENSE

Copyright 2012 el autor.

Todos los derechos reservados.

Puede usar, copiar, modificar, distribuir y vender este software, reconociendo a
su autor original y de acuerdo con los términos de la licencia GPL. (GNU General
Public License).

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
our $VERSION = substr q$Revision: 3.2 $, 10;
my $is_win = `uname -a` =~ /Microsoft/;
my $void = 'echo %s';

# }}}
# {{{ Variables
my $file;
my $ext;
my $type;
my $BAT;
my $CHM;
my $DIR;
my $EBOOK;
my $EDITOR;
my $EXCEL;
my $IMAGE;
my $PDF;
my $PPT;
my $TORRENT;
my $VBS;
my $VIDEO;
my $VISIO;
my $WEB;
my $WORD;
my %opt;
my @files;

# Programs to use depending on operative system
if ($is_win) {
    $BAT     = 'cmd /c        %s';
    $CHM     = 'explorer.exe  %s';
    $DIR     = 'explorer.exe  %s';
    $EBOOK   = 'explorer.exe  %s';
    $EDITOR  = 'vim           %s';
    $EXCEL   = 'explorer.exe  %s';
    $IMAGE   = 'explorer.exe  %s';
    $PDF     = 'explorer.exe  %s';
    $PPT     = 'explorer.exe  %s';
    $TORRENT = $void;
    $VBS     = 'cscript //Nologo %s';
    $VIDEO   = 'explorer.exe  %s';
    $VISIO   = 'explorer.exe  %s';
    $WEB     = 'explorer.exe  %s';
    $WORD    = 'explorer.exe  %s';
} else {
    $BAT     = 'cmd.exe /c    %s';
    $CHM     = 'kchmviewer    %s';
    $DIR     = 'xdg-open      %s >/dev/null &';
    $EBOOK   = 'fbreader      %s >/dev/null 2>/dev/null ';
    $EDITOR  = 'vim           %s';
    $EXCEL   = 'libreoffice   %s&';
    $IMAGE   = 'eom           %s&';
    $PDF     = 'zathura       %s >/dev/null 2>/dev/null &';
    $PPT     = 'libreoffice   %s >/dev/null 2>/dev/null &';
    $TORRENT = 'magnet        %s';
    $VBS     = $void;
    $VIDEO   = 'celluloid     %s&';
    $VISIO   = $void;
    $WEB     = 'brave-browser %s 2>/dev/null >/dev/null &',
    $WORD    = 'libreoffice   %s&';
}
# Extensiones
my %extensions = (
    'ACE archive data'          => 'ln -s %s /tmp/x.ace ;unace l /tmp/x.ace;rm /tmp/x.ace',
    'Apple QuickTime movie'     => $VIDEO,
    'Audio file with ID3'       => $VIDEO,
    'ISO 9660 '                 => 'isoinfo -J -l -i %s',
    'ISO Media, MP4 Base Media' => $VIDEO,
    'ISO Media, MP4'            => $VIDEO,
    'ISO Media, MPEG-4'         => $VIDEO,
    'JPEG Image Data'           => $IMAGE,
    'Joliet SVD'                => 'isoinfo -J -l -i %s',
    'MP3 file'                  => $VIDEO,
    'MPEG ADTS'                 => $VIDEO,
    'MPEG sequence'             => $VIDEO,
    'MPEG transport stream'     => $VIDEO,
    'MS Windows HtmlHelp Data'  => $CHM,
    'Macromedia Flash Video'    => $VIDEO,
    'Media, MPEG'               => $VIDEO,
    'Microsoft ASF'             => $VIDEO,
    'Microsoft Excel'           => $EXCEL,
    'Microsoft Office Document' => $WORD,
    'Microsoft PowerPoint 2007+'=> $PPT,
    'Mobipocket E-Book'         => $EBOOK,
    'Ogg data, .* video'        => $VIDEO,
    'OpenDocument'              => $WORD,
    'PDF Document'              => $PDF,
    'PNG Image Data'            => $IMAGE,
    'POSIX tar '                => 'tar tvf    %s|tarcolor',
    'RAR archive data'          => 'rar l       %s',
    'RIFF.*AVI'                 => $VIDEO,
    'Rich Text Format'          => $WORD,
    'UDF filesystem data'       => 'isoinfo -l -i %s',
    'WAVE audio'                => $VIDEO,
    'WebM'                      => $VIDEO,
    'XZ compressed data'        => 'unxz -l      %s',
    'Zip archive data'          => 'ln -s %s /tmp/x.zip ;unzip -l /tmp/x.zip;rm /tmp/x.zip',
    'ascii.* text'              => $EDITOR,
    'directory'                 => $DIR,
    'iso-8859 .* text'          => $EDITOR,
    'matroska'                  => $VIDEO,
    'perl script'               => $EDITOR,
    'shell script'              => $EDITOR,
    'tar archive'               => 'tar tvf    %s|tarcolor',
    'wrapped MPEG-1'            => $VIDEO,
    'Unicode text, UTF-8 text'  => $EDITOR,
    '7-Zip archive data'        => '7z l %s',
    '^.7z$'                     => '7z l %s',
    '^.arj$'                    => '7z l %s',
    '^.avi$'                    => $VIDEO,
    '^.bat$'                    => $BAT,
    '^.bmp$'                    => $IMAGE,
    '^.cab$'                    => '7z l %s',
    '^.chm$'                    => $CHM,
    '^.dmg$'                    => '7z l %s',
    '^.csv$'                    => $EXCEL,
    '^.djvu$'                   => 'djview      %s',
    '^.doc$'                    => $WORD,
    '^.deb$'                    => 'dpkg -c %s',
    '^.docx$'                   => $WORD,
    '^.dot$'                    => $WORD,
    '^.gif$'                    => $IMAGE,
    '^.gz$'                     => 'zless       %s',
    '^.htm$'                    => $WEB,
    '^.html$'                   => $WEB,
    '^.iso$'                    => 'isoinfo -l -i %s',
    '^.jpg$'                    => $IMAGE,
    '^.lrf$'                    => 'lrfviewer   %s',
    '^.log$'                    => 'less        %s',
    '^.lzh$'                    => '7z l %s',
    '^.fb2$'                    => $EBOOK,
    '^.epub$'                   => $EBOOK,
    '^.md$'                     => 'okular %s',
    '^.mobi$'                   => $EBOOK,
    '^.mkv$'                    => $VIDEO,
    '^.mov$'                    => $VIDEO,
    '^.mp3$'                    => $VIDEO,
    '^.mpg$'                    => $VIDEO,
    '^.msi$'                    => '7z l %s',
    '^.ods$'                    => $WORD,
    '^.ogg$'                    => $VIDEO,
    '^.pdf$'                    => $PDF,
    '^.pgn$'                    => 'scid        %s',
    '^.png$'                    => $IMAGE,
    '^.pps$'                    => $PPT,
    '^.ppt$'                    => $PPT,
    '^.pptx$'                   => $PPT,
    '^.prc$'                    => $EBOOK,
    '^.rar$'                    => 'rar l       %s',
    '^.rtf$'                    => $WORD,
    '^.rpm$'                    => 'rpm -qlp    %s',
    '^.sxc$'                    => $EXCEL,
    '^.sxw$'                    => $EXCEL,
    '^.tar$'                    => 'tar tvf    %s|tarcolor',
    '^.tgz$'                    => 'tar tvf    %s|tarcolor',
    '^.txz$'                    => 'tar tvf    %s|tarcolor',
    '^.tbz2'                    => 'tar tvf   %s|tarcolor',
    '^.torrent$'                => $TORRENT,
    '^.tga$'                    => $IMAGE,
    '^.tiff$'                   => $IMAGE,
    '^.txt$'                    => $EDITOR,
    '^.vbs$'                    => $VBS,
    '^.vsd$'                    => $VISIO,
    '^.vdx$'                    => $VISIO,
    '^.wav$'                    => $VIDEO,
    '^.wmv$'                    => $VIDEO,
    '^.wim$'                    => '7z l %s',
    '^.xar$'                    => '7z l %s',
    '^.xls$'                    => $EXCEL,
    '^.xz$'                     => 'unxz -l      %s',
    '^.zip$'                    => 'unzip -l      %s',
    '^.jar$'                    => 'unzip -l      %s',
);

# }}}
# {{{ Parametros
getopts("dhtuvV", \%opt ) or usage("Fallo parámetros");
help()  if $opt{h};
usage() if $opt{u};
if ($opt{V}){version();exit 1;}
@files = @ARGV;
@ARGV = qw//;

# }}}
#==============================================================================#
# MAIN                                                                         #
#==============================================================================#
# {{{
while ( $file = shift @files ) {
    print "FILE: $file\n" if $opt{v};
    $ext   = $file;
    $ext   =~ s/tar.gz$/tgz/;
    $ext   =~ s/tar.xz$/txz/;
    $ext   =~ s/tar.bz2$/tbz2/;
    $ext   =~ s/.*\././;
    $type  = `file "$file"`;
    $type  =~ s/$file: *//;
    $type  =~ s/\n+//;
    my $sw = 0;
    for my $i ( sort keys %extensions ) {
        if ( $ext  =~ /$i/i) {
            ext_execute( $i, $file );
            $sw = 1;
            last;
        }
    }
    if (!$sw){
        for my $i ( sort keys %extensions ) {
            if ( $type =~ /$i/i ) {
                ext_execute( $i, $file );
                $sw = 1;
                last;
            }
        }
    }
    print "TIPO Desconocido: $type\n" unless $sw;
    if ( $opt{d} ) {
        print "-- Lo borramos?\n";
        my $l = <>;
        if ( $l =~ /^[YS]/i  and !$opt{t}) {
            system "rm  \"$file\"\n" ;
            print "Borrado.\n"
        }
    }
}
# }}}
exit 0;
#==============================================================================#
# FUNCTIONS                                                                    #
#==============================================================================#
# {{{
sub ext_execute {
    # get appropiate command to execute and do it.
    my $ext  = shift;
    my $file = shift;
    my $line = $extensions{$ext};
    print "Executing $ext\n" if $opt{v};
    print "$file\n" if $opt{d};
    $line =~ s/%s/"$file"/g;
    print "$line\n" if $opt{v};
    system $line unless $opt{t};
}
# }}}
