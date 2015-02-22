package config;
use strict;
use vars qw($VERSION @ISA @EXPORT);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(parse_config);
$VERSION = 1.0;
use Data::Dumper;
# http://www.patshaping.de/hilfen_ta/codeschnipsel/perl-configparser.htm
sub parse_config
{

 # my $file = shift;
 my $file = "GVL_File_send.GVL";
 local *CF;
 # print $file . "\n";
 open(CF,'<'.$file) or die "Open $file: $!";
 read(CF, my $data, -s $file);
 close(CF);

 my @lines  = split(/\015\012|\012|\015/,$data);
 my @config = "";
 my $count  = 0;
 #print Dumper(@lines);
 foreach my $line(@lines)
 {
 
 
   # if($line eq "VAR_GLOBAL"){next;} # wenn 'VAR_GLOBAL' ueberspringen
   # if($line eq "END_VAR"){next;}    # wenn 'END_VAR' ueberspringen
    # next if($line =~ /^\s*#/);     # Kommentar Zeilen ueberspringen
    # next if($line !~ /^\s*\S+\s*=.*$/);
    $line =~ s/^\s+//g;     # Remove whitespaces at the beginning and at the end
    $line =~ s/\s+$//g;
    $line =~ s/\s+//g;      # alle Leerzeichen entfernen
    
    chop($line);            # letztes Zeichen entfernen, alternativ  $line = substr($line,0,-2); 
    if(substr($line, 0, 4) eq "KNX_") {
       # print "gefunden>$line< \n";
       $line =~ s/^KNX_//g;    # KNX_ wird entfernt
       $line =~ s/_/\//g;      # alle _ durch / ersetzen
       $config[$count] = $line;
       $count++;
    }
    
 }
 #print "\n";
 #print Dumper(@config);
 #print "----- \n";
return @config;
# ($name, $inhalt) = split(/=/,$wert,2);
}
1;