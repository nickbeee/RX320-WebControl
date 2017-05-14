#!perl -w
#
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Pretty;
#use strict;
#
#
#
my $q = new CGI;
#
print $q->header,
$q->start_html(-title =>'RX-320 Control'),
$q->h2('RX320 Perl Controller');
#
#
&DoForm;
#
print $q->end_html;
#
#
sub DoForm
{
	print start_form();
	print p ("Frequency", textfield('QRG','10000',6,10), strong("kHz"));
	print p (radio_group('MODE',['AM','USB','LSB','CW'],'AM'));
	print p ("Bandwidth ",popup_menu('FILTER',['8000','6000','5700','5400','5100','4800','4500',
						'4200','3900','3600','3300','3000','2850','2700','2550',
						'2400','2250','2100','1950','1800','1650','1500','1350',
						'1200','1050','900','750','675','600','525','450',
						'375','330','300'],'6000')," Hz");
	print p(popup_menu('AGC', ['SLOW', 'MEDIUM', 'FAST'],'MEDIUM'));
	print p ("CW pitch", popup_menu('CBFO' ,['400','500','600','700','800'],'600'), strong(" Hz"));
	my $v;
	my @vol;
	# @vol build an array of values
	for ($v=0; $v<64; $v++)
	{
		push (@vol, $v)
		}
	print p(popup_menu('VOL',[@vol],'0'), popup_menu('LINE', [@vol], '31'));
	print p(submit('UPDATE'));
	print end_form;
	}	
#

		
#

#