use Test;
BEGIN { plan tests => 3 };

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

my $sig = $api->sign_args({'foo' => 'bar'});

ok($sig eq '466cd24ced0b23df66809a4d2dad75f8');
