use strict;
use warnings;
use Test::More tests => 26;
use File::Temp ();

use Flickr::API;


########################################################
#
# create a generic flickr api with oauth consumer object
#

my $key    = 'My_Made_up_Key';
my $secret = 'My_little_secret';

my $api = Flickr::API->new({
						 'consumer_key'    => $key,
						 'consumer_secret' => $secret,
						});

isa_ok($api, 'Flickr::API');
is($api->is_oauth, 1, 'Does Flickr::API object identify as OAuth');
is($api->get_oauth_request_type(), 'consumer', 'Does Flickr::API object identify as consumer request');

########################################################
#
# make sure it returns the required message params
#

my %config = $api->oauth_export_config('consumer', 'message');
is($config{'consumer_key'}, $key,
   'Did oauth_export_config return the consumer_key in consumer/message request');
is($config{'signature_method'}, 'HMAC-SHA1',
   'Did oauth_export_config return the correct signature_method in consumer/message request');
like($config{'nonce'}, qr/[0-9a-f]+/i,
	  'Did oauth_export_config return a nonce in consumer/message request');
like($config{'timestamp'}, qr/[0-9]+/i,
	  'Did oauth_export_config return a timestamp in consumer/message request');

########################################################
#
# make sure it returns the required api params
#

undef %config;
%config = $api->oauth_export_config('consumer', 'api');
is($config{'consumer_secret'}, $secret,
   'Did oauth_export_config return the consumer_secret in consumer/api request');
is($config{'request_method'}, 'GET',
   'Did oauth_export_config return the correct request_method in consumer/api request');
is($config{'request_url'}, 'https://api.flickr.com/services/rest/',
   'Did oauth_export_config return the correct request_url in consumer/api request');






undef %config;
undef $api;

##################################################################
#
# create a generic flickr api with oauth protected resource object
#

my $token        = 'a-fake-oauth-token-for-generic-tests';
my $token_secret = 'my-embarassing-secret-exposed';

$api = Flickr::API->new({
							'consumer_key'    => $key,
							'consumer_secret' => $secret,
							'token'           => $token,
							'token_secret'    => $token_secret,
						});

isa_ok($api, 'Flickr::API');
is($api->is_oauth, 1, 'Does Flickr::API object identify as OAuth');
is($api->get_oauth_request_type(), 'protected resource',
   'Does Flickr::API object identify as protected resource request');


##################################################################
#
# make sure it also returns the required message params
#

%config = $api->oauth_export_config('protected resource', 'message');
is($config{'consumer_key'}, $key,
   'Did oauth_export_config return the consumer_key in protected resource/message request');
is($config{'token'}, $token,
   'Did oauth_export_config return the token in protected resource/message request');
is($config{'signature_method'}, 'HMAC-SHA1',
   'Did oauth_export_config return the correct signature_method in protected resource/message request');
like($config{'nonce'}, qr/[0-9a-f]+/i,
	  'Did oauth_export_config return a nonce in protected resource/message request');
like($config{'timestamp'}, qr/[0-9]+/i,
	 'Did oauth_export_config return a timestamp in protected resource/message request');



########################################################
#
# make sure it also returns the required api params
#

undef %config;
%config = $api->oauth_export_config('protected resource', 'api');
is($config{'consumer_secret'}, $secret,
   'Did oauth_export_config return the consumer_secret in protected resource/api request');
is($config{'token_secret'}, $token_secret,
   'Did oauth_export_config return the token_secret in protected resource/api request');
is($config{'request_method'}, 'GET',
   'Did oauth_export_config return the correct request_method in protected resource/api request');
is($config{'request_url'}, 'https://api.flickr.com/services/rest/',
   'Did oauth_export_config return the correct request_url in protected resource/api request');

my $FH    = File::Temp->new();
my $fname = $FH->filename;

$api->oauth_export_storable_config($fname);

my $fileflag=0;
if (-r $fname) { $fileflag = 1; }
is($fileflag, 1, "Did oauth_export_storable_config produce a readable config");

my $api2 = Flickr::API->oauth_import_storable_config($fname);

isa_ok($api2, 'Flickr::API');

is_deeply($api2->{oauth}, $api->{oauth}, "Did oauth_import_storable_config get back the config we stored");

########################################################
#
# check private method
#


my $nonce = $api->_make_nonce();
like( $nonce, qr/[0-9a-f]+/i,
	  'Did _make_nonce return a nonce when asked');


exit;

# Local Variables:
# mode: Perl
# End:
