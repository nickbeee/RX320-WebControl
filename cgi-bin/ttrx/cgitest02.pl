#!perl -w
#
# a file to save the form values to
open(RX320, ">> rx320.txt");
#
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
use strict;
save_parameters(*RX320);
#
#
print header, start_html(-title =>'RX-320 Control');
print h2("RX320 Perl Controller");
&DoFreqForm;
&DoModeForm;
&DoBwForm;
&DoAgcForm;
&DoBfoForm;
&DoVolForm;
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
	my $vol = param('VOL');
	my $line = param('LINE');
	print p("Vol: ", strong($vol), "Line: ", strong($line));
} 

#
#
#
print p ("I\'m remembering how perl works!");
print end_html();
#
close(RX320);
#
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
#
#
sub DoFreqForm
{
	print start_form("POST");
	print p ("Frequency", textfield('QRG','',6,10), submit('kHz'));
	print p, end_form;
	}
#
#
sub DoModeForm
{
	print start_form("POST");
	print p(radio_group('MODE',['AM','USB','LSB','CW'],'AM'), submit('Mode'));
	print p, end_form;
	}
#
#
sub DoBwForm
{
	print start_form("POST");
	print p("Bandwidth ",popup_menu('FILTER',['8000','6000','5700','5400','5100','4800','4500',
						'4200','3900','3600','3300','3000','2850','2700','2550',
						'2400','2250','2100','1950','1800','1650','1500','1350',
						'1200','1050','900','750','675','600','525','450',
						'375','330','300'],'6000')," Hz  ", submit('Bandwidth'));
	print p, end_form;
	}
#
#
sub DoAgcForm
{
	print start_form("POST");
	print p(popup_menu('AGC', ['SLOW', 'MEDIUM', 'FAST'],'MEDIUM'),submit('AGC'));
	print p, end_form;
	}
#
#
sub DoBfoForm
{
	print start_form("POST");
	print p (("CW pitch", popup_menu('CBFO' ,['400','500','600','700','800'],'600')), submit('Hz'));
	print p, end_form;
	}
#
#
sub DoVolForm
{	
	my $v;
	my @vol;
	# @vol build an array of values
	for ($v=0; $v<64; $v++)
	{
		push (@vol, $v)
		}
	print start_form("POST");
	print p(popup_menu('VOL',[@vol],'0'), popup_menu('LINE', [@vol], '31'), submit('Vol'));
	print p, end_form;
} 
	