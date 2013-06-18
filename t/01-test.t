use strict;
use warnings;

use Test::More tests => 20;

use Flickr::API;


##################################################
#
# create an api object
#

my $api = Flickr::API->new({
		'key' => 'made_up_key',
		'secret' => 'my_secret',
	});
isa_ok $api, 'Flickr::API';
my $rsp = $api->execute_method('fake.method', {});
isa_ok $rsp, 'Flickr::API::Response';


##################################################
#
# check we get the 'method not found' error
#

SKIP: {
	skip "skipping error code check, since we couldn't reach the API", 1
		if $rsp->{_rc} ne '200';
	# this error code may change in future!
	is($rsp->{error_code}, 112, 'checking the error code for "method not found"');
}


##################################################
#
# check the 'format not found' error is working
#

$rsp = $api->execute_method('flickr.test.echo', {format => 'fake'});

SKIP: {
	skip "skipping error code check, since we couldn't reach the API", 1
		if $rsp->{_rc} ne '200';
	is($rsp->{error_code}, 111, 'checking the error code for "format not found"');
}


##################################################
#
# check the signing works properly
#

is($api->sign_args({'foo' => 'bar'}), '466cd24ced0b23df66809a4d2dad75f8', "Signing test 1");
is($api->sign_args({'foo' => undef}), 'f320caea573c1b74897a289f6919628c', "Signing test 2");

$api->{unicode} = 0;
is('b8bac3b2a4f919d04821e43adf59288c', $api->sign_args({'foo' => "\xE5\x8C\x95\xE4\xB8\x83"}), "Signing test 3 (unicode=0)");

$api->{unicode} = 1;
is('b8bac3b2a4f919d04821e43adf59288c', $api->sign_args({'foo' => "\x{5315}\x{4e03}"}), "Signing test 4 (unicode=1)");

##################################################
#
# check the auth url generator is working
#

my $uri = $api->request_auth_url('r', 'my_frob');

my %expect = parse_query('api_sig=d749e3a7bd27da9c8af62a15f4c7b48f&perms=r&frob=my_frob&api_key=made_up_key');
my %got = parse_query($uri->query);

sub parse_query {
	return split /[&=]/, shift;
}
foreach my $item (keys %expect) {
	is($expect{$item}, $got{$item}, "Checking that the $item item in the query matches");
}
foreach my $item (keys %got) {
	is($expect{$item}, $got{$item}, "Checking that the $item item in the query matches in reverse");
}

is($uri->path, '/services/auth/', "Checking correct return path");
is($uri->host, 'api.flickr.com', "Checking return domain");
is($uri->scheme, 'http', "Checking return protocol");


##################################################
#
# check we can't generate a url without a secret
#

$api = Flickr::API->new({'key' => 'key'});
$uri = $api->request_auth_url('r', 'frob');

is($uri, undef, "Checking URL generation without a secret");

