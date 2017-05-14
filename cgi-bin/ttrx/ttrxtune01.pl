#!perl -w
# TTRXTUNE.PL
#

#
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use strict;
#
# This form displays the parameters then forwards back to the main data entry form.
#
print header, 
start_html(-title =>'Tuned...',
-head =>meta({-http_equiv => 'refresh',
		-content=> '1; URL=ttrxform03.pl'}));
print h2('Updating...');
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
	my $vol = param('VOL');
	my $line = param('LINE');
	print p("Vol: ", strong($vol), "Line: ", strong($line));
	# Save state to file
	# a file to save the form values to
	open(RX320, "> rx320.txt");
	save_parameters(*RX320);
	close(RX320);
} 
#
#
my $mainform = 'ttrxform03.pl';
print p("<a href=\"$mainform\">MAIN FORM</a>");
print end_html;