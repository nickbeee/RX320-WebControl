#!perl -w
# TTRXTUNE.PL
#

#
use CGI qw(:standard *div);
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use strict;
my $mainform = 'ttrxform04.pl';
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
	$qrg= param('QRG');
	if (($qrg < 50) or ($qrg > 30000)) {
		print header, 
		start_html(-title =>'Not Tuned...',
		-style=>{-src=>'/rx.css'},
		-head =>meta({-http_equiv => 'refresh',
			-content=> "5; URL=$mainform"}));
		print start_div({-id=> 'main'});
		print h2('Frequency out of range');
		print p('Must be between 50 and 30,000kHz');
	
}
else {	&UpdatePanel; }
}


#
# Called without Params
if (!param()) {
	print header, 
	start_html(-title =>'Not Tuned...',
	-style=>{-src=>'/rx.css'},
	-head =>meta({-http_equiv => 'refresh',
		-content=> "1; URL=$mainform"}));
	print start_div({-id=> 'main'});
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
sub UpdatePanel
{
	print header, 
	start_html(-title =>'Updating...',
	-style=>{-src=>'/rx.css'},
	-head =>meta({-http_equiv => 'refresh',
		-content=> "5; URL=$mainform"}));
	print start_div({-id=> 'main'});
	print h2('Updating RX...');
	print start_div({-id=> 'panel'});
	$qrg = param('QRG');
	print p("Frequency ",textfield('QRG',$qrg,6)," kHz");
	$mode = param('MODE');
	print p("MODE ",radio_group('MODE',['AM','USB','LSB','CW'],$mode));
	$filter = param('FILTER');
	print p("Bandwidth ", textfield('FILTER',$filter,4)," Hz");
	$agc = param ('AGC');
	print p("AGC ",textfield('AGC',$agc,7));
	$pbt = param ('PBT');
	print p("PBT ", textfield('PBT',$pbt,5), " Hz");
	$cbfo = param('CBFO');
	print p("CW pitch ", textfield('CBFO',$cbfo,4)," Hz");
	$vol = param('VOL');
	$line = param('LINE');
	print p("Vol: ", textfield('VOL',$vol,2), "Line: ", textfield('LINE',$line,2));
	print end_div();
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
sub TuneRx
{
}