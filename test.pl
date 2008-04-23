use Test;
BEGIN { plan tests => 8 };

use Flickr::API;
ok(1); #

##################################################
#
# create an api object
#

my $api = new Flickr::API({
		'key' => 'made_up_key',
		'secret' => 'my_secret',
	});
my $rsp = $api->execute_method('fake.method', {});


##################################################
#
# check we get the 'method not found' error
#

ok($rsp->{error_code} == 0); # this error code will change in future!

#print "code was $rsp->{error_code}, msg was $rsp->{error_message}\n";


##################################################
#
# check the signing works properly
#

ok('466cd24ced0b23df66809a4d2dad75f8' eq $api->sign_args({'foo' => 'bar'}));
ok('f320caea573c1b74897a289f6919628c' eq $api->sign_args({'foo' => undef}));


##################################################
#
# check the auth url generator is working
#

my $uri = $api->request_auth_url('r', 'my_frob');

ok($uri->query eq 'api_sig=d749e3a7bd27da9c8af62a15f4c7b48f&perms=r&frob=my_frob&api_key=made_up_key');
ok($uri->path eq '/services/auth');
ok($uri->host eq 'flickr.com');
ok($uri->scheme eq 'http');


##################################################
#
# check we can't generate a url without a secret
#

$api = new Flickr::API({'key' => 'key'});
$uri = $api->request_auth_url('r', 'frob');

ok(!defined $uri);

