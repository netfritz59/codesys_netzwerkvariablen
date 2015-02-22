#! /usr/bin/perl
use warnings;
use strict;
use Socket qw(:all);
use Data::Dumper;
use config;      # Perl Modul config.pm einbinden
use knx_write;   # Perl Modul knx_write.pm einbinden
my @configs = parse_config; # Codes config Netwerkvariablen
# print Dumper(@configs);
$|++; # no suffering from buffering
my $L_byte = "";
my $H_byte = "";
#my $d_typ = "";
my $i = 0;
my $hex_str = "";
my $var = "";
# Broadcast auf Port 1202
my $udp_port = 1202;
socket( UDPSOCK, PF_INET, SOCK_DGRAM, getprotobyname('udp') ) or die "socket: $!";
select( ( select(UDPSOCK), $|=1 )[0] ); # no suffering from buffering
setsockopt( UDPSOCK, SOL_SOCKET, SO_REUSEADDR, 1 )
    or die "setsockopt SO_REUSEADDR: $!";
setsockopt( UDPSOCK, SOL_SOCKET, SO_BROADCAST, 1 )
    or die "setsockopt SO_BROADCAST: $!";
my $broadcastAddr = sockaddr_in( $udp_port, INADDR_ANY );
bind( UDPSOCK, $broadcastAddr ) or die "bind failed: $!\n";
#
my $input;
while( my $addr = recv( UDPSOCK, $input, 256,0) ) {
    my $hex = unpack "H*", $input;        # ganzen hex String
    my @hex_byte    = ($hex =~ /(..)/g);  # in byte aufteilen
    # print Dumper(@hex_byte);
    my $sub_index = hex($hex_byte[9])*256 + hex($hex_byte[10]); # sub_index aus Codesys Telegramm
    $i = 20; 
    my ($var,$d_typ) = split(/:/,$configs[$sub_index],2); # variable und Datentyp(Codesys) aus config holen 
    if($d_typ eq "INT"){
        # von INT nach DPT9
        my $dez = hex($hex_byte[$i+1])*256 + hex($hex_byte[$i]);
        if ($dez > 32768){  
          # wenn > 32768 dann negativ Value 
          $dez = (32768 - ($dez -32768)) * -1;  
        }
        knx_write($var,$dez,"9"); 
    }elsif ($d_typ eq "BOOL") {
        # von BOOL nach DTP1
        my $dez = hex($hex_byte[$i]);
        knx_write($var,$dez,"1");
    }   
}               
