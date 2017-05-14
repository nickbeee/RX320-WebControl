#!perl
#
# TTRXCalc - to check the tuning calculations and make portable
# SUBs for main programs.
#
# everything apart from the follwing requires the tuning factor to be re-calculated:
# - volume(V) - line level(A) - combined(C) 
# 
use Win32::SerialPort;
use strict;

my $Tfreq    = 999;    #entered freq in kHz - convert to Hz.
my $filter   = 2400;    #Filter bandwidth
my $filterno = 14;      # filter number from %filterh

my $mode = 1;           #AM
my $pbt  = 000;           #PBT -2000 -> +2000 Hz
my $cbfo = 600;         #CW BFO in kHz

#my $mcor;             # mode correction derived from mode
my $Cr   = chr(13);     # terminator for command strings (or use \r)
my $agc  = 1;           # AGC from %agch
my $vol  = 40;          # vol level
my $line = 58;          #line level

my $Smeter;
my $SmeterCmd = "X\r";

my $RxTuneCmd = TuneRx( $Tfreq, $filter, $mode, $pbt, $cbfo );
print "RxTuneCmd: $RxTuneCmd\n";
my $SetModeCmd = SetMode($mode);
print "SetModeCmd: $SetModeCmd\n";
my $SetFilterCmd = SetFilter($filterno);
print "SetFilterCmd: $SetFilterCmd\n";
my $SetAgcCmd = SetAgc($agc);
print "SetAgcCmd: $SetAgcCmd\n";
my $SetVolCmd = SetVol($vol);
print "SetVolCmd: $SetVolCmd\n";
my $SetLineCmd = SetLine($line);
print "SetLineCmd: $SetLineCmd\n";
my $SetMuteCmd = SetMute();
print "SetMuteCmd: $SetMuteCmd\n";
#
#SendToRx("COM1", "$SetVolCmd");
#
$Smeter = SendToRx("COM1", "$SetVolCmd");
print "S-meter: $Smeter\n";

#
#
sub TuneRx {
    my ( $Tfreq, $filter, $mode, $pbt, $cbfo ) = @_;    # passed parameters
    my $mcor;
    my $Cr = chr(13);
    if ( ( $mode le "3" ) and ( $mode ge "0" ) ) {
        if ( $mode eq "0" ) { $mcor = 0 }
        if ( $mode eq "1" ) { $mcor = 1 }
        if ( ( $mode eq "2" ) or ( $mode eq "3" ) ) { $mcor = -1 }
    }

    #
    # set BFO to 0 unless mode is CW. If CW set PBT to 0.
    if ( $mode ne "3" ) { $cbfo = 0 }
    if ($mode eq "3"){$pbt=0};
    #
    #
    print "Mode: $mode Correction Factor: $mcor\n";

    #
    #
    # Convert Tfreq to Hz
    # TODO: Error check within range
    $Tfreq = $Tfreq * 1000;

    #
    # Filter correction factor
    my $Fcor = ( $filter / 2 ) + 200.0;
    print "Filter BW: $filter Filter correction: $Fcor Hz\n";

    #
    # Adjusted Tuning Frequency
    my $AdjTfreq = $Tfreq - 1250 + ( int( $mcor * ( $Fcor + $pbt ) ) );
    print "Tuned Frequency: $Tfreq Hz\n";
    print "Adjusted Tuning Frequency: $AdjTfreq Hz\n";

    # Coarse Tuning Factor
    my $ctf = int( $AdjTfreq / 2500 + 18000 );

    # Fine tuning factor
    my $ftf = int( ( $AdjTfreq % 2500 ) * 5.46 );

    # BFO tuning factor
    my $btf = int( ( $Fcor + $pbt + $cbfo + 8000.0 ) * 2.73 );
    print "Coarse Tuning Factor: $ctf\n";
    print "Fine Tuning Factor: $ftf\n";
    print "BFO Tuning Factor: $btf\n";

#
# split them into hi/lo byte and Hex. We actually send the ASCII char to the radio not the hex.
# my $Ch = sprintf("%X",int($ctf/256));
# my $Cl = sprintf("%X",int($ctf %256));
#
#
# We actually send the ASCII char to the radio not the hex.
    my $Ch = chr( int( $ctf / 256 ) );
    my $Cl = chr( int( $ctf % 256 ) );
    my $Fh = chr( int( $ftf / 256 ) );
    my $Fl = chr( int( $ftf % 256 ) );
    my $Bh = chr( int( $btf / 256 ) );
    my $Bl = chr( int( $btf % 256 ) );

    # Finally, the tuning string:
    my $RxTune = "N$Ch$Cl$Fh$Fl$Bh$Bl\r";
    return ($RxTune);
}

#

sub SetFilter {

    # Returns filter setting command.
    # filter value from %filterh hash.
    my ($filternum) = @_;                #passed parameter
    my $fn          = chr($filternum);
    my $filterset   = "W$fn\r";
    return ($filterset);
}

#
#
sub SetMode {

    # Returns Mode setting command
    # Mode value from %modeh hash
    my ($modenum) = @_;
    my $mn        = $modenum;    #NOT chr($modenum) ??
    my $modeset   = "M$mn\r";
    return ($modeset);
}

#
sub SetAgc {

    # AGC value from %agch hash
    my ($agc) = @_;
    my $agcset = "G$agc\r";
    return ($agcset);
}

#
sub SetVol {

    # Returns volume set command
    # value 0-63 THIS WORKS IN REVERSE it is an attenuator
    my ($volnum) = @_;
    my $vn       = chr( 63 - $volnum );
    my $volset   = "VV$vn\r";
    return ($volset);
}

#
sub SetLine {

    # Returns line level set command
    # value 0-63 THIS WORKS IN REVERSE it is an attenuator
    my ($volnum) = @_;
    my $vn       = chr( 63 - $volnum );
    my $volset   = "AA$vn\r";
    return ($volset);
}

#
sub SetMute {

    # returns mute set command.
    # This uses C (combined vol + line command)
    # to set both to zero (ok then, 63...)
    my $mute    = chr(63);
    my $muteset = "CC$mute\r";
    return ($muteset);
}

#
#
sub SendToRx
{
	# send commands to radio via COM port.
	# 1200 8N1
	my ($PortName, $RxCmd) = @_;
	my $quiet =1;
	#create the object
	my $RadioPort = new Win32::SerialPort ($PortName, $quiet); 
	#set the properties
	$RadioPort -> baudrate(1200);
	$RadioPort->databits(8);
    $RadioPort->parity("none");
    $RadioPort->stopbits(1);
    $RadioPort->write_settings || undef $RadioPort;
    #write data to port
    $RadioPort ->write($SetVolCmd);
    $RadioPort ->write($SetLineCmd);
    $RadioPort ->write($SetModeCmd);
    $RadioPort ->write($SetAgcCmd);
    $RadioPort ->write($SetFilterCmd);
    $RadioPort ->write($RxTuneCmd);
    #flush buffers
    $RadioPort ->lookclear;
    #send S-meter interrogator
    $RadioPort ->write($SmeterCmd);
    sleep(0.1);
    #get 4 bytes (X Hb Lb <cr>)
    my($count,$meter) = $RadioPort->read(4);
    undef $RadioPort;
    #print "S-meter: $meter\n";
    return ($meter);
} 
