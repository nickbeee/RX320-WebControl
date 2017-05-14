#!perl -w
#VOLUMEFORM.PL
# For local control of Volume and LINE levels

#
use CGI qw(:standard *div *table *Tr *th *td);
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use strict;
#
#
#
# If form called with no params them retrieve state from file. This is OK for single-user
# but breaks for multi-user (Mozilla bug?).
# Now forwards to second page (this will do RX control) then back to here.
if ( !param() ) {

    # Get state from file
    open( VOLUME, "< admin.txt" );
    restore_parameters(*VOLUME);
    close(VOLUME);

    # this overrides _all_ values entered in form!
}

my $NextForm = "volumecontrol.pl";

#
print header( -expires => 'now' ),
  start_html(
    -title => 'RX-320 Volume and Line Levels',
    -style => { -src => '/rx.css' },
    -head  => meta(
        {
            -http_equiv => 'refresh',
            -content    => '60'
        }
    )
  );

#
print start_div( { -id => 'main' } );
print h2("Gain Control Panel");
&DoVolForm;


#
#
#
#
print hr();
print p('&copy; Nick G4IRX 2007. A work in progress...');
print end_div();
print end_html();

#
#
#
#
sub DoVolForm {
    print start_div( { -id => 'panel' } );
    print start_form( "POST", "$NextForm" );
    my $v;
    my @vol;

    # @vol build an array of values
    for ( $v = 0 ; $v < 64 ; $v++ ) {
        push( @vol, $v );
    }
    print p( "Vol: ", popup_menu( 'VOL', [@vol], '0' ),
        "Line: ", popup_menu( 'LINE', [@vol], '31' ) );
    print p( submit('UPDATE'), reset ), end_form;
    print end_div();
}

#
