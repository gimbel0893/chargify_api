
use strict;
use warnings;

require LWP::UserAgent;
use Chargify;

use Data::Dumper;
 


warn "\n\nSTARTING APP\n\n";

my $chargify = Chargify->new();
$chargify->init();
$chargify->make_secure_info();

warn Dumper( $chargify->{secure_info} );

$chargify->do_test_call();

warn "\n\nLEAVING APP\n\n";

