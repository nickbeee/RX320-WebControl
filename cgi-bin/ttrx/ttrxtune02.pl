#!perl -w
# TTRXTUNE.PL
#

#
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use strict;
my $mainform = 'ttrxform03.pl';
#
# This form displays the parameters then forwards back to the main data entry form.
#
# Define the (global) variables
my (%modeh, %modecorh, %filterh, %agch);
my ($qrg, $filter, $mode, $agc, $cbfo, $vol, $line, $modeval, $modecorval,
	 $filterval, $agcval, $pbt);
#

#
#
#
# Hashes containing translations for MODE, FILTER, AGC.
# MODE
%modeh = ( AM => 0, USB => 1, LSB => 2, CW => 3);
#
# Mode correction (for tuning calculation)
%modecorh = ( AM => 0, USB => 1, LSB => -1, CW => -1);
#
# FILTER
%filterh = (6000 => 0, 5700 => 1, 5400 => 2, 5100 => 3, 4800 => 4, 
			4500 => 5, 4200 => 6, 3900 => 7, 3600 => 8, 3300 => 9,
			3000 => 10, 2850 => 11, 2700 => 12, 2550 => 13, 2400 => 14,
			2250 => 15, 2100 => 16, 1950 => 17, 1800 => 18, 1650 => 19,
			1500 => 20, 1350 => 21, 1200 => 22, 1050 => 23, 900 => 24,
			750 => 25, 675 => 26, 600 => 27, 525 => 28, 450 => 29,
			375 => 30, 330 => 31, 300 => 32, 8000 => 33);
#
# AGC
%agch = (SLOW => 1, MEDIUM => 2, FAST => 3);
#
# Process if the script was called with params
if (param()) {
	print header, 
	start_html(-title =>'Tuned...',
	-head =>meta({-http_equiv => 'refresh',
		-content=> "10; URL=$mainform"}));
	print h2('Updating RX...');
	$qrg = param('QRG');
	print p("Frequency: ",strong($qrg)," kHz");
	$filter = param('FILTER');
	print p("Bandwidth: ", strong($filter)," Hz");
	$mode = param('MODE');
	print p("Mode: ",strong($mode));
	$pbt = param ('PBT');
	print p("PBT: ", strong($pbt), " Hz");
	$agc = param ('AGC');
	print p("AGC: ",strong($agc));
	$cbfo = param('CBFO');
	print p("CW pitch: ", strong($cbfo)," Hz");
	$vol = param('VOL');
	$line = param('LINE');
	print p("Vol: ", strong($vol), "Line: ", strong($line));
	$modeval = $modeh{$mode};
	$modecorval = $modecorh{$mode};
	$filterval = $filterh{$filter};
	$agcval = $agch{$agc};
	print p("Mode value: ", $modeval);
	print p("Mode correction: ", $modecorval);
	print p("Filter value: ", $filterval);
	print p ("AGC value: ", $agcval ); 
	# Save state to file
	# a file to save the form values to
	open(RX320, "> rx320.txt");
	save_parameters(*RX320);
	close(RX320);
} 
#
# Called without Params
if (!param()) {
	print header, 
	start_html(-title =>'Not Tuned...',
	-head =>meta({-http_equiv => 'refresh',
		-content=> "1; URL=$mainform"}));
	print h2('Returning...');
}
#	
# Finish the HTML footer
print p("<a href=\"$mainform\">MAIN FORM</a>");
print end_html;
#
#
# 
sub TuneRx
{
}