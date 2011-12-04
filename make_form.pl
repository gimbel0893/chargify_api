
use strict;
use warnings;

require LWP::UserAgent;
use Chargify;



my $chargify = Chargify->new();
$chargify->init();
$chargify->make_secure_info();

$chargify->print_submit_form();

