#!perl -w
# VOLUMECONTROL.PL
#

#
use CGI qw(:standard *div);
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use strict;
use Win32::SerialPort;

#
my $mainform = 'volumeform.pl';

#
# This form displays the parameters then forwards back to the main data entry form.
#
# Define the (global) variables

my ($vol, $line, $SetVolCmd, $SetLineCmd, $SetMuteCmd);

#

my $Cr         = chr(13);    # terminator for command strings (or use \r)
my $serialport = "COM2";

my $Smeter;
my $SmeterCmd = "X\r";

# Process if the script was called with params
if ( param() ) {
        my $vol      = param('VOL');
        my $line     = param('LINE');
        $SetVolCmd    = SetVol($vol);
        $SetLineCmd   = SetLine($line);
        $SetMuteCmd   = SetMute();

        #
        #Tune the Receiver, return S-Meter
        my $Smeter = SendToRx("$serialport");

        #

        &UpdatePanel;
        }


#
# Called without Params
if ( !param() ) {
    print header,
      start_html(
        -title => 'Not Changed...',
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
    $vol  = param('VOL');
    $line = param('LINE');
    print p( "Vol: ", textfield( 'VOL', $vol, 2 ),
        "Line: ", textfield( 'LINE', $line, 2 ) );
    print end_div();
   
    # Save state to file
    # a file to save the form values to
    open( VOLUME, "> admin.txt" );
    save_parameters(*VOLUME);
    close(VOLUME);
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
    $RadioPort->write($SetVolCmd);
    $RadioPort->write($SetLineCmd);

    #flush buffers
    $RadioPort->lookclear;

    #send S-meter interrogator
    $RadioPort->write($SmeterCmd);

    #sleep(1);
    #get 4 bytes (X Hb Lb <cr>)
    my ( $count, $meter ) = $RadioPort->read(4);
    undef $RadioPort;

    #print "S-meter: $meter\n";
    return ($meter);
}
