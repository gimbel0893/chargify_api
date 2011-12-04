package Chargify;

use strict;
use warnings;

use LWP::UserAgent;
use URI::Escape;
use Digest::SHA;
use JSON;

use Data::Dumper;

use constant RAILS_ENV => 'development';



sub new
{
    my( $class ) = @_;

    my $self = bless( {}, $class );

    return $self;
}

sub init
{
    my( $self ) = @_;

    $self->{api_key} = '_lQy5ce7fnheZ-SlmdEH';
    $self->{shared_key} = RAILS_ENV eq 'production' ? '6jFC6_6kt2Rfa8b_B9Tn': '50bmi704gJ9APhpDID3d';
    $self->{subdomain} = RAILS_ENV eq 'production' ? 'picket-report-widget': 'picketreport-testing';
    $self->{base_url} = 'https://' . $self->{subdomain} . '.chargify.com/';

    $self->{redirect_uri} = RAILS_ENV eq 'production' ? 'picket-report-widget': 'picketreport-testing';
    $self->{product_id} = '78144';
    $self->{product_handle} = 'basic';

    $self->{_ua} = my $ua = LWP::UserAgent->new();
    $ua->env_proxy();
    $ua->timeout(10);
    $ua->credentials( $self->{subdomain} . '.chargify.com:443', 'Chargify API', '_lQy5ce7fnheZ-SlmdEH', 'x' );
    $ua->default_header( 'Content-Type' => 'application/json' );
    $ua->default_header( 'Accept' => 'application/json' );
    $ua->agent( '' );

    return $self;
}

sub make_secure_info
{
    my( $self ) = @_;

    $self->{secure_info}{api_id} = $self->{api_key};

    $self->{secure_info}{timestamp} = time();

    my @chars = ( 0..9, 'a'..'z', 'A'..'Z' );
    $self->{secure_info}{nonce} = join( '', map { @chars[ int( rand( scalar( @chars ) ) ) ] } 1..40 );

    my $redirect_uri = 'redirect_uri=' . URI::Escape::uri_escape( $self->{redirect_uri} );
    my $secure_data = 'signup[product][id]=' . URI::Escape::uri_escape( $self->{product_id} ) . '&signup[product][handle]=' . URI::Escape::uri_escape( $self->{product_handle} );
    $self->{secure_info}{data} = "$redirect_uri&$secure_data";

    my $message = "$self->{secure_info}{api_id}$self->{secure_info}{timestamp}$self->{secure_info}{nonce}$self->{secure_info}{data}";
    $self->{secure_info}{signature} = Digest::SHA::sha1_hex( $message, $self->{shared_key} );

    return $self;
}



sub print_submit_form
{
    my( $self ) = @_;

    print << "PRINT_DONE";
<form method="POST" action="https://api.chargify.com/api/v2/signups">
    <input type="hidden" name="secure[api_id]" value="$self->{secure_info}{api_id}" />
    <input type="hidden" name="secure[timestamp]" value="$self->{secure_info}{timestamp}" />
    <input type="hidden" name="secure[nonce]" value="$self->{secure_info}{nonce}" />
    <input type="hidden" name="secure[data]" value="$self->{secure_info}{data}" />
    <input type="hidden" name="secure[signature]" value="$self->{secure_info}{signature}" />

<!--
    <input type="text" name="signup[customer][first_name]" />
    <input type="text" name="signup[customer][last_name]" />
    <input type="text" name="signup[customer][email]" />
    <input type="text" name="signup[payment_profile][first_name]" />
    <input type="text" name="signup[payment_profile][last_name]" />
    <input type="text" name="signup[payment_profile][card_number]" />
    <input type="text" name="signup[payment_profile][expiration_month]" />
    <input type="text" name="signup[payment_profile][expiration_year]" />
-->
          
    <input type="submit" value="Submit" />
</form>
PRINT_DONE

    return $self;

}

sub do_test_call
{
    my( $self ) = @_;

    warn "making test call\n";

    my $ua = $self->{_ua};
    #my $response = $ua->get( 'https://picketreport-testing.chargify.com/subscriptions.xml' );
    #my $response = $ua->get( 'https://picketreport-testing.chargify.com/product_families.xml' );
    my $response = $ua->get( 'https://picketreport-testing.chargify.com/products.xml' );
 
    if( $response->is_success() )
    {
        warn "SUCCESS\n" . $response->decoded_content();
    }
    else
    {
        warn "FAILED\n" . $response->status_line();
    }

    warn "done with test call\n";

}

sub call_subscription
{
    my( $self ) = @_;

    warn "making subscription call\n";

    my $ua = $self->{_ua};
    my $data = {
        subscription => {
            product_handle => $self->{product_handle},
            customer_attributes => {
                first_name => 'Joe',
                last_name => 'Blow',
                email => 'joe3@example.com',
            },
            credit_card_attributes => {
                full_number => 1,
                expiration_month => 10,
                expiration_year => 2020,
            },
        },
    };
    my $json_data = JSON::encode_json( $data );
    warn $json_data;
    warn Dumper( $ua->default_headers() );
    my $request = HTTP::Request->new( 'POST', 'https://picketreport-testing.chargify.com/subscriptions.json', $ua->default_headers(), $json_data );
    my $response = $ua->request( $request );

#curl -u _lQy5ce7fnheZ-SlmdEH:x -H Accept:application/json -H Content-Type:application/json -d '{"subscription":{ "product_handle":"basic", "customer_attributes":{ "first_name":"Joe", "last_name":"Blow", "email":"joe2@example.com" }, "credit_card_attributes":{ "full_number":"1", "expiration_month":"10", "expiration_year":"2020" } }}' https://picketreport-testing.chargify.com/subscriptions.json

    if( $response->is_success() )
    {
        warn "SUCCESS\n" . $response->decoded_content();
    }
    else
    {
        warn "FAILED\n" . $response->status_line();
    }

    warn "done with subscription call\n";


}



1;
