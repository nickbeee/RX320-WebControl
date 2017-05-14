#!perl -w
#TTRXFORM.PL
#version 05
#
use CGI qw(:standard *div *table *Tr *th *td);
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use strict;

#
#
#
# Get Remote ip by whatever means, try to detect proxy servers etc.
# code from YaBB.
my $user_ip = $ENV{'REMOTE_ADDR'};
if ( $user_ip eq "127.0.0.1" ) {
    if ( $ENV{'HTTP_CLIENT_IP'} && $ENV{'HTTP_CLIENT_IP'} ne "127.0.0.1" ) {
        $user_ip = $ENV{'HTTP_CLIENT_IP'};
    }
    elsif ( $ENV{'X_CLIENT_IP'} && $ENV{'X_CLIENT_IP'} ne "127.0.0.1" ) {
        $user_ip = $ENV{'X_CLIENT_IP'};
    }
    elsif ($ENV{'HTTP_X_FORWARDED_FOR'}
        && $ENV{'HTTP_X_FORWARDED_FOR'} ne "127.0.0.1" )
    {
        $user_ip = $ENV{'HTTP_X_FORWARDED_FOR'};
    }
}

#
# If called from CHAT, enter text into chatlog
if ( param('CHAT') ) {
    my $ChatMsg = param('CHAT');
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      gmtime();
    gmtime(time);
    open( CHATLOG, ">>chatlog.txt" ) || die "$!";
    print CHATLOG "\n$hour:$min $user_ip: $ChatMsg";
    close(CHATLOG);
}

# If form called with no params them retrieve state from file. This is OK for single-user
# but breaks for multi-user (Mozilla bug?).
# Now forwards to second page (this will do RX control) then back to here.
# if ( !param() ) {

# Get RX state from file
open( RX320, "< rx320.txt" );
restore_parameters(*RX320);
close(RX320);

# this overrides _all_ values entered in form!
#}

my $ThisForm = self_url;
my $NextForm = "ttrxtune05.pl";

#
print header( -expires => 'now' ),
  start_html(
    -title => 'RX-320 Control::',
    -style => { -src => '/rx.css' },
    -head  => meta(
        {
            -http_equiv => 'refresh',
            -content    => '60'
        }
    )
  );

#

#print h1("Remote RX-320");
print end_div();    #top
print start_div( { -id => 'forms' } );
&DoSmeter;
&DoForm;
&DoChat;
&DoMemory;
print end_div();    #forms

#

=pod
# Save state to file
	 a file to save the form values to
	 open(RX320, "> rx320.txt");
	 save_parameters(*RX320);
	 close(RX320);
#
=cut

=pod
# Print out the params so we can see what changed...
if (param()) {
	my $qrg = param('QRG');
	print p("Frequency: ",strong($qrg)," kHz");
	my $filter = param('FILTER');
	print p("Bandwidth: ", strong($filter)," Hz");
	my $mode = param('MODE');
	print p("Mode: ",strong($mode));
	my $agc = param ('AGC');
	print p("AGC: ",strong($agc));
	my $cbfo = param('CBFO');
	print p("CW pitch: ", strong($cbfo)," Hz");
	
} 
=cut

#
#
#
#
print start_div( { -id => 'bottom' } );

#print hr();
#print p('&copy; Nick G4IRX 2007. A work in progress...');
print end_div();    #bottom
print end_html();

#
#
#
# TODO - in progress
sub DoSmeter {
	my $meterbg = "#FFFFFF";
	# get value from file
	open(SMETER, "<smeter.txt"); 
	my $Smeter = <SMETER>;
	chomp($Smeter);
	close(SMETER);
	#Convert to dBuv
	if   ($Smeter > 7500){$Smeter = 80; $meterbg="#FF0000";}
	elsif($Smeter > 7400){$Smeter = 70; $meterbg="#FF0000";}
	elsif($Smeter > 7300){$Smeter = 60; $meterbg="#FF0000";}
	elsif($Smeter > 7200){$Smeter = 50; $meterbg="#FF0000";}
	elsif($Smeter > 5800){$Smeter = 40; $meterbg="#FFFF00";}
	elsif($Smeter > 1800){$Smeter = 30; $meterbg="#FFFF00";}
	elsif($Smeter > 580){$Smeter = 20; $meterbg="#00FF00";}
	elsif($Smeter > 180){$Smeter = 10; $meterbg="#00FF00";}
	elsif($Smeter > 60){$Smeter = 0; $meterbg="#00FF00";}
	elsif($Smeter > 10){$Smeter = -10; $meterbg="#00FF00";}
	else {$Smeter = "_";}
	print start_div( { -id => 'smeter' } );

    #start of S-meter
    print p(
        param('QRG'),
        "kHz",
        span(
            { -style => "background: $meterbg; border: 1px solid;" },
            "$Smeter"
        ),"dBu"
    );

    #end of S-meter
    print end_div();

}

sub DoForm {
    print start_div( { -id => 'panel' } );
    print h2("Control Panel");
    print start_form( "GET", "$NextForm" );
    print p ( "Frequency", textfield( 'QRG', '10000', 6, 10 ), strong("kHz") );
    print p( "MODE ",
        radio_group( 'MODE', [ 'AM', 'USB', 'LSB', 'CW' ], 'AM' ) );
    print p (
        "Bandwidth ",
        popup_menu(
            'FILTER',
            [
                '8000', '6000', '5700', '5400', '5100', '4800',
                '4500', '4200', '3900', '3600', '3300', '3000',
                '2850', '2700', '2550', '2400', '2250', '2100',
                '1950', '1800', '1650', '1500', '1350', '1200',
                '1050', '900',  '750',  '675',  '600',  '525',
                '450',  '375',  '330',  '300'
            ],
            '6000'
        ),
        strong(" Hz")
    );
    print p( "AGC ",
        popup_menu( 'AGC', [ 'SLOW', 'MEDIUM', 'FAST' ], 'MEDIUM' ) );
    print p ( "PBT ", textfield( 'PBT', '0', 5 ), strong("Hz") );
    print p (
        "CW pitch",
        popup_menu(
            'CBFO',
            [ '300', '350', '400', '500', '600', '700', '800', '900', '1360' ],
            '600'
        ),
        strong(" Hz")
    );

=pod
    my $v;
    my @vol;

    # @vol build an array of values
    for ( $v = 0 ; $v < 64 ; $v++ ) {
        push( @vol, $v );
    }
    print p( "Vol: ", popup_menu( 'VOL', [@vol], '0' ),
        "Line: ", popup_menu( 'LINE', [@vol], '31' ) );
=cut

    print p( submit('TUNE'), reset ), end_form;
    print end_div();
}

#
sub DoMemory

  #print a tune-able list of memories (from a file)

{

    #load memories from file
    open( MEMORIES, "< memory.txt" );
    my @MemArray = <MEMORIES>;

    close(MEMORIES);

    #remove comment lines
    if ( m/^#/, @MemArray ) {

        #print "COMMENT!";
        shift @MemArray;
    }

    #start the table
    print start_div( { -id => 'memory' } );
    print h3("Tuning Presets");
    print start_table(
        { -border => '1', -cellpadding => '5', -cellspacing => '0' } );
    print Tr(
        th(
            [
                'Frequency', 'Mode',        'BWidth', 'AGC',
                'PBT',       'Description', '&nbsp;'
            ]
        )
    );


    foreach my $memory (@MemArray) {

        my ( $Freq, $Mode, $BWidth, $Agc, $Pbt, $Description ) =
          split( /,/, $memory );

        print Tr(
            { -id => 'row1' },
            td(
                [
                    $Freq, $Mode, $BWidth, $Agc, $Pbt,
                    $Description,
                    a(
                        {
                            href =>
"/cgi-bin/$NextForm?QRG=$Freq&MODE=$Mode&FILTER=$BWidth&AGC=$Agc&PBT=$Pbt"
                        },
                        "TUNE"
                    )
                ]
            )
        );

    }

    print end_table();
    print end_div();
}

#

sub DoChat {
    my ( $ChatText, @ChatLogText );
    open( LOGFILE, "<chatlog.txt" );
    @ChatLogText = <LOGFILE>;
    @ChatLogText = splice( @ChatLogText, -9 );
    $ChatText = join( '', @ChatLogText );
    close(LOGFILE);
    print start_div( { -id => 'chat' } );
    print h3("Chat Log - Please ask here before you tune!");
    print start_form( "POST", "/cgi-bin/ttrxform05.pl" );
    print p( textarea( 'CHATLOG', $ChatText, 10, 60 ) );
    print p ( "Message: ", textfield( 'CHAT', '',, 60 ) );
    print p( submit('SEND'), reset('Clear') ), end_form;
    print end_div();
}

