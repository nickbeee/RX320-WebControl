#!perl -w
#TTRXFORM.PL

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
if (!param())
{
	# Get state from file
	open(RX320, "< rx320.txt");
	restore_parameters(*RX320);
	close(RX320);
# this overrides _all_ values entered in form!
}

my $NextForm = "ttrxtune04.pl";
	
#
print header(-expires => 'now'),
 start_html(-title =>'RX-320 Control',
 -style=>{-src=>'/rx.css'},
-head =>meta({-http_equiv => 'refresh',
		-content=> '60'}));
#
print start_div({-id=> 'main'});
print h2("RX-320 Control Panel");
&DoForm;
&DoMemory;
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
	my $vol = param('VOL');
	my $line = param('LINE');
	print p("Vol: ", strong($vol), "Line: ", strong($line));
} 
=cut
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
sub DoForm
{
	print start_div({-id=> 'panel'});
	print start_form("POST", "$NextForm");
	print p ("Frequency", textfield('QRG','10000',6,10), strong("kHz"));
	print p("MODE ", radio_group('MODE',['AM','USB','LSB','CW'],'AM'));
	print p ("Bandwidth ",popup_menu('FILTER',['8000','6000','5700','5400','5100','4800','4500',
						'4200','3900','3600','3300','3000','2850','2700','2550',
						'2400','2250','2100','1950','1800','1650','1500','1350',
						'1200','1050','900','750','675','600','525','450',
						'375','330','300'],'6000'),strong(" Hz"));
	print p("AGC ",popup_menu('AGC', ['SLOW', 'MEDIUM', 'FAST'],'MEDIUM'));
	print p ("PBT ", textfield('PBT','0',5), strong("Hz"));
	print p ("CW pitch", popup_menu('CBFO' ,['300','350','400','500','600','700','800'],'600'), strong(" Hz"));
	my $v;
	my @vol;
	# @vol build an array of values
	for ($v=0; $v<64; $v++)
	{
		push (@vol, $v)
		}
	print p("Vol: ",popup_menu('VOL',[@vol],'0'),"Line: ",popup_menu('LINE', [@vol], '31'));
	print p(submit('UPDATE'), reset), end_form;
	print end_div();
	}
#
sub DoMemory
#print a tune-able list of memories (from a file)
{
	print start_div({-id=> 'memory'});
	print h3("Tuning Presets");
	print start_table({-border=> '1', -cellpadding=>'5', -cellspacing=>'0'});
	print Tr(th(['Frequency','Mode','BWidth','AGC','PBT','Description','&nbsp;']));
	#sample print out TODO read from file.
	print Tr({-id=> 'row1'}, td(['5450','USB','2400','SLOW','0', 'RAF Volmet',a({href=>"#"},"TUNE")]));
	print Tr({-id=> 'row2'}, td(['5505','USB','2400','SLOW','0', 'Shannon Volmet',a({href=>"#"},"TUNE")]));
	print end_table();
	print end_div();
}
			
#
	
