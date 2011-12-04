
use strict;
use warnings;
use JSON;
use Data::Dumper;

my $subscription = {
    subscription => {
        product_handle => 'basic',
        customer_attributes => {
            first_name => 'first_name_01',
            last_name => 'last_name_01',
            email => 'email_01@test.com',
            reference => 'profile_id_01',
        },
        payment_profile_attributes => {
        },
    },
};

my $json = JSON::encode_json( $subscription );

print "\n\n\n$json\n\n\n";

