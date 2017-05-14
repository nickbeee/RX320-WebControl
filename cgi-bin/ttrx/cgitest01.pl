#!perl -w
#test for CGI functions
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use strict;
print header, start_html(-title =>'RX-320 Control');
print h2("RX320 Perl Controller");
&DoForm;
#
# If I'm going to use perl to control the RX320D I might as well get it to 
# generate the forms stuff as well!
# it would be useful of the form got its state from a file? or does CGI do that?
# - use param() and !param()...
# - Think multi-user...
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

#
#my $myself = self_url;
#print p("<a href=\"$myself\">I'm talking to myself.</a>");
#
print p ("I forgot how perl works!");
print end_html();
#
sub DoForm
{
	print start_form("POST");
	print p ("Frequency", textfield('QRG','15000',6,10), strong("kHz"));
	print p, radio_group('MODE',['AM','USB','LSB','CW'],'USB');
	print p ("Bandwidth ",popup_menu('FILTER',['8000','6000','5700','5400','5100','4800','4500',
						'4200','3900','3600','3300','3000','2850','2700','2550',
						'2400','2250','2100','1950','1800','1650','1500','1350',
						'1200','1050','900','750','675','600','525','450',
						'375','330','300'],'2700')," Hz");
	print p, popup_menu('AGC', ['SLOW', 'MEDIUM', 'FAST'],'MEDIUM');
	print p ("CW pitch", popup_menu('CBFO' ,['400','500','600','700','800'],'600'), strong(" Hz"));
	print p, submit('TUNE','TUNE'), end_form;
	}	