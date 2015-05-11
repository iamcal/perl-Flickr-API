use strict;
use warnings;
use Test::More tests => 4;

use Flickr::API;

##################################################
#
# create an api object
#

my $api = Flickr::API->new({
		'consumer_key' => 'made_up_key',
		'consumer_secret' => 'my_secret',
	});

isa_ok $api, 'Flickr::API';


##################################################
#
# is the api object using OAuth
#
is($api->is_oauth, 1, 'Does api object identify as OAuth');


##################################################
#
# make sure api does not use flickr native arg signing
#
is($api->sign_args({'foo' => 'bar'}), undef, 'api should not try to sign_args under OAuth');


##################################################
#
# make sure api does not use flickr native auth request url
#
is($api->request_auth_url('r', 'my_frob'), undef, 'api should not try to request_auth_url under OAuth');


exit;
