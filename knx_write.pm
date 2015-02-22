package knx_write;
use strict;
use vars qw($VERSION @ISA @EXPORT);
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(knx_write);
$VERSION = 1.0;
use Data::Dumper;
sub knx_write {
       my $dst = shift;
       my $value = shift;
       my $dpt = shift;
   #print "dst= $dst value= $value dpt= $dpt \n";
   # exit;
if($dpt==1){system("groupswrite ip:localhost $dst $value");}
elsif($dpt==5)
 {
   my $knx_value = encode_dpt5($value);
   #print Dumper(@knx_value);
   system("groupswrite ip:localhost $dst $knx_value");
 }
elsif($dpt==9)
 {
   my @knx_value = encode_dpt9($value); 
   #print Dumper(@knx_value);
   my $knx0 = sprintf("%x", $knx_value[0]);
   my $knx1 = sprintf("%x", $knx_value[1]);
   my $knx_hex = "$knx0 $knx1";
   # print "knx_value= $knx_hex";
   system("groupwrite ip:localhost $dst $knx_hex");
 } 

# system("groupswrite ip:localhost $dst $value");
# exit;
}

    #     DPT 1 (1 bit) = EIS 1/7 (move=DPT 1.8, step=DPT 1.7)
    #     DPT 2 (1 bit controlled) = EIS 8
    #     DPT 3 (3 bit controlled) = EIS 2
    #     DPT 4 (Character) = EIS 13
    #     DPT 5 (8 bit unsigned value) = EIS 6 (DPT 5.1) oder EIS 14.001 (DPT 5.10)
    #     DPT 6 (8 bit signed value) = EIS 14.000
    #     DPT 7 (2 byte unsigned value) = EIS 10.000
    #     DPT 8 (2 byte signed value) = EIS 10.001
    #     DPT 9 (2 byte float value) = EIS 5
    #     DPT 10 (Time) = EIS 3
    #     DPT 11 (Date) = EIS 4
    #     DPT 12 (4 byte unsigned value) = EIS 11.000
    #     DPT 13 (4 byte signed value) = EIS 11.001
    #     DPT 14 (4 byte float value) = EIS 9
    #     DPT 15 (Entrance access) = EIS 12
    #     DPT 16 (Character string) = EIS 15


sub encode_dpt5 {
    my $value = shift;
    $value = 100 if ( $value > 100 );
    $value = 0   if ( $value < 0 );
    my $byte = sprintf( "%.0f", $value * 255. / 100 );
    return ($byte);
}

sub encode_dpt9 {    # 2byte signed float
    my $state = shift;
    my $data;

    my $sign = ( $state < 0 ? 0x8000 : 0 );
    my $exp  = 0;
    my $mant = 0;

    $mant = int( $state * 100.0 );
    while ( abs($mant) > 2047 ) {
        $mant /= 2;
        $exp++;
    }
    $data = $sign | ( $exp << 11 ) | ( $mant & 0x07ff );
    return $data >> 8, $data & 0xff;
}

sub decode_dpt5 {    #1byte unsigned percent
    return sprintf( "%.1f", hex(shift) * 100. / 255 );    # /
}

# decode DPT9.001/EIS 5
sub decode_dpt9 {
    my @data = @_;
    my $res;

    unless ( $#data == 2 ) {
        ( $data[1], $data[2] ) = split( ' ', $data[0] );
        $data[1] = hex $data[1];
        $data[2] = hex $data[2];
        unless ( defined $data[2] ) {
            return;
        }
    }
    my $sign = $data[1] & 0x80;
    my $exp  = ( $data[1] & 0x78 ) >> 3;
    my $mant = ( ( $data[1] & 0x7 ) << 8 ) | $data[2];

    $mant = -( ~( $mant - 1 ) & 0x7ff ) if $sign != 0;
    $res = ( 1 << $exp ) * 0.01 * $mant;
    return $res;
}
1;