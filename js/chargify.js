
var api_key = '_lQy5ce7fnheZ-SlmdEH';
var shared_key = '50bmi704gJ9APhpDID3d';
var subdomain = 'picketreport-testing';
var base_url_wauth = 'https://' + api_key + ':x@' + subdomain + '.chargify.com/';
var base_url = 'https://' + subdomain + '.chargify.com/';

$(document).ready( function(){

    $('.chargify_btn_submit').click( function(){
        list_products();
    });

});

function list_products()
{
    $.ajax({
        username: api_key,
        password: 'x',
        url: base_url + 'subscriptions.json',
        accept: 'application/json',
        contentType: 'application/json',
        type: 'GET',
        success:
            function( response )
            {
                alert( response );
            }
    });
}

