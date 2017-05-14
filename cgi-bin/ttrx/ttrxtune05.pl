#!perl -w
# TTRXTUNE.PL
#
# version 05
#
use CGI qw(:standard *div);
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use strict;
use Win32::SerialPort;

#
my $mainform = 'ttrxform05.pl';
#my $RemoteHost = remote_host();
# Get Remote ip by whatever means, try to detect proxy servers etc.
# code from YaBB.
my $user_ip = $ENV{'REMOTE_ADDR'};
if ($user_ip eq "127.0.0.1")
{
	if    ($ENV{'HTTP_CLIENT_IP'} && $ENV{'HTTP_CLIENT_IP'} ne "127.0.0.1") {$user_ip = $ENV{'HTTP_CLIENT_IP'};}
	elsif ($ENV{'X_CLIENT_IP'} && $ENV{'X_CLIENT_IP'} ne "127.0.0.1") {$user_ip = $ENV{'X_CLIENT_IP'};}
	elsif ($ENV{'HTTP_X_FORWARDED_FOR'} && $ENV{'HTTP_X_FORWARDED_FOR'} ne "127.0.0.1") {$user_ip = $ENV{'HTTP_X_FORWARDED_FOR'};}
}

#
# This form displays the parameters then forwards back to the main data entry form.
#
# Define the (global) variables
my ( %modeh, %modecorh, %filterh, %agch );
my (
    $qrg,       $filter,       $mode,      $agc,        $cbfo,
    $vol,       $line,         $modeval,   $modecorval, $filterval,
    $agcval,    $pbt,          $SetVolCmd, $SetLineCmd, $SetModeCmd,
    $SetAgcCmd, $SetFilterCmd, $RxTuneCmd, $SetMuteCmd
);

#

my $Cr         = chr(13);    # terminator for command strings (or use \r)
my $serialport = "COM1";

my $Smeter;
my $SmeterCmd = "X\r";

#
#
#
# Hashes containing translations for MODE, FILTER, AGC.
# MODE
%modeh = ( AM => 0, USB => 1, LSB => 2, CW => 3 );

#
# Mode correction (for tuning calculation)
%modecorh = ( AM => 0, USB => 1, LSB => -1, CW => -1 );

#
# FILTER
%filterh = (
    6000 => 0,
    5700 => 1,
    5400 => 2,
    5100 => 3,
    4800 => 4,
    4500 => 5,
    4200 => 6,
    3900 => 7,
    3600 => 8,
    3300 => 9,
    3000 => 10,
    2850 => 11,
    2700 => 12,
    2550 => 13,
    2400 => 14,
    2250 => 15,
    2100 => 16,
    1950 => 17,
    1800 => 18,
    1650 => 19,
    1500 => 20,
    1350 => 21,
    1200 => 22,
    1050 => 23,
    900  => 24,
    750  => 25,
    675  => 26,
    600  => 27,
    525  => 28,
    450  => 29,
    375  => 30,
    330  => 31,
    300  => 32,
    8000 => 33
);

#
# AGC
%agch = ( SLOW => 1, MEDIUM => 2, FAST => 3 );

#
# Process if the script was called with params
if ( param() ) {
    $qrg = param('QRG');
    if ( ( $qrg < 50 ) or ( $qrg > 30000 ) ) {
        print header,
          start_html(
            -title => 'Not Tuned...',
            -style => { -src => '/rx.css' },
            -head  => meta(
                {
                    -http_equiv => 'refresh',
                    -content    => "2; URL=$mainform"
                }
            )
          );
        print start_div( { -id => 'main' } );
        print h2('Frequency out of range');
        print p('Must be between 50 and 30,000kHz');

    }
    else {

        # Tests for params OK, we can tune RX and update panel
        my $Tfreq    = param('QRG');
        my $filter   = param('FILTER');
        my $filterno = $filterh{$filter};
        my $vol      = param('VOL');
        my $line     = param('LINE');
        my $agc      = param('AGC');
        my $agcno    = $agch{$agc};
        $mode       = param('MODE');
        $modeval    = $modeh{$mode};
        $modecorval = $modecorh{$mode};
        $pbt        = param('PBT');
        $cbfo       = param('CBFO');

        #my $mode = $modecorh{param'MODE'};
        
        # Write tuning params to chatlog.txt
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = gmtime();                                           gmtime(time);
        open (CHATLOG, ">>chatlog.txt") || die "$!";
        print CHATLOG "\n$hour:$min $user_ip: $Tfreq $mode $filter $agc $pbt";
        close (CHATLOG); 
        
        #Write metadata to file for OddCast
        open (METADATA, ">metadata.txt") ||die "$!";
        print METADATA "$Tfreq kHz $mode\n";
        close (METADATA);
        
        $RxTuneCmd =
          TuneRx( $Tfreq, $filter, $modeval, $modecorval, $pbt, $cbfo );
        $SetModeCmd   = SetMode($modeval);
        $SetFilterCmd = SetFilter($filterno);
        $SetAgcCmd    = SetAgc($agcno);
        $SetVolCmd    = SetVol($vol);
        $SetLineCmd   = SetLine($line);
        $SetMuteCmd   = SetMute();

        #
        #Tune the Receiver, return S-Meter
        my $Smeter = SendToRx("$serialport");
        # write S-meter to file
        open (SMETER, ">smeter.txt") || die "$!";
        print SMETER "$Smeter";
        close (SMETER); 
        #

        &UpdatePanel;
    }
}

#
# Called without Params
if ( !param() ) {
    print header,
      start_html(
        -title => 'Not Tuned...',
        -style => { -src => '/rx.css' },
        -head  => meta(
            {
                -http_equiv => 'refresh',
                -content    => "1; URL=$mainform"
            }
        )
      );
    print start_div( { -id => 'main' } );
    print h2('Returning...');
}

#
# Finish the HTML footer
print p("<a href=\"$mainform\">MAIN FORM</a>");
print end_div();
print end_html;

#
#
#
#
sub UpdatePanel {
    print header,
      start_html(
        -title => 'Updating...',
        -style => { -src => '/rx.css' },
        -head  => meta(
            {
                -http_equiv => 'refresh',
                -content    => "1; URL=$mainform"
            }
        )
      );
    print start_div( { -id => 'main' } );
    print h2('Updating RX...');
    print start_div( { -id => 'panel' } );
    $qrg = param('QRG');
    print p( "Frequency ", textfield( 'QRG', $qrg, 6 ), " kHz" );
    $mode = param('MODE');
    print p( "MODE ",
        radio_group( 'MODE', [ 'AM', 'USB', 'LSB', 'CW' ], $mode ) );
    $filter = param('FILTER');
    print p( "Bandwidth ", textfield( 'FILTER', $filter, 4 ), " Hz" );
    $agc = param('AGC');
    print p( "AGC ", textfield( 'AGC', $agc, 7 ) );
    $pbt = param('PBT');
    print p( "PBT ", textfield( 'PBT', $pbt, 5 ), " Hz" );
    $cbfo = param('CBFO');
    print p( "CW pitch ", textfield( 'CBFO', $cbfo, 4 ), " Hz" );
=pod
    $vol  = param('VOL');
    $line = param('LINE');
    print p( "Vol: ", textfield( 'VOL', $vol, 2 ),
        "Line: ", textfield( 'LINE', $line, 2 ) );
=cut
    print end_div();
    $modeval    = $modeh{$mode};
    $modecorval = $modecorh{$mode};
    $filterval  = $filterh{$filter};
    $agcval     = $agch{$agc};
    print p( "Mode value: ",      $modeval );
    print p( "Mode correction: ", $modecorval );
    print p( "Filter value: ",    $filterval );
    print p ( "AGC value: ", $agcval );

    # Save state to file
    # a file to save the form values to
    open( RX320, "> rx320.txt" );
    save_parameters(*RX320);
    close(RX320);
}

#
sub TuneRx {
    my ( $Tfreq, $filter, $mode, $mcor, $pbt, $cbfo ) = @_;  # passed parameters
    my $Cr = chr(13);
    my ( $cwbias);

    # set BFO to 0 unless mode is CW. If CW set PBT to 0.
   
    if ( $mode eq "3" ) { 
    #$pbt = 0;
    $cwbias = -300; }   
    if ( $mode ne "3" ) { 
    $cbfo = 0;
    $cwbias=0;
     }
   

    #
    #
    #print "Mode: $mode Correction Factor: $mcor\n";

    #
    #
    # Convert Tfreq to Hz
    # TODO: Error check within range
    $Tfreq = $Tfreq * 1000;

    #
    # Filter correction factor
    my $Fcor = ( $filter / 2 ) + 200.0;

    #print "Filter BW: $filter Filter correction: $Fcor Hz\n";

    #
    # Adjusted Tuning Frequency
    my $AdjTfreq = $Tfreq - 1250 + ( int( $mcor * ( $Fcor + $pbt + $cwbias ) ) );

    #print "Tuned Frequency: $Tfreq Hz\n";
    #print "Adjusted Tuning Frequency: $AdjTfreq Hz\n";

    # Coarse Tuning Factor
    my $ctf = int( $AdjTfreq / 2500 + 18000 );

    # Fine tuning factor
    my $ftf = int( ( $AdjTfreq % 2500 ) * 5.46 );

    # BFO tuning factor
    my $btf = int( ( $Fcor + $pbt + $cwbias + $cbfo + 8000.0 ) * 2.73 );

    #print "Coarse Tuning Factor: $ctf\n";
    #print "Fine Tuning Factor: $ftf\n";
    #print "BFO Tuning Factor: $btf\n";

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
    my $mn        = $modenum;
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
sub SendToRx {
    
    # send commands to radio via COM port.
    # 1200 8N1
    my ($PortName) = @_;
    my $quiet = 1;

    #create the object
    my $RadioPort = new Win32::SerialPort( $PortName, $quiet );

    #set the properties
    $RadioPort->baudrate(1200);
    $RadioPort->databits(8);
    $RadioPort->parity("none");
    $RadioPort->stopbits(1);
    $RadioPort->write_settings || undef $RadioPort;

    #write data to port
    #$RadioPort->write($SetVolCmd);
    #$RadioPort->write($SetLineCmd);
    $RadioPort->write($SetAgcCmd);
    $RadioPort->write($SetFilterCmd);
    $RadioPort->write($RxTuneCmd);
    $RadioPort->write($SetModeCmd);

    #flush buffers
    $RadioPort->lookclear;

    #send S-meter interrogator
    $RadioPort->write($SmeterCmd);

    #sleep probably not ideal. Loop?
    #sleep(1);
    $RadioPort->read_interval(100);
    #get 4 bytes (X Hb Lb <cr>)
    my ( $count, $meter ) = $RadioPort->read(4);
    undef $RadioPort;

    #print "S-meter: $meter\n";
    return ($meter);
}
