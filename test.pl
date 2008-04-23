# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 2 };
use Flickr::API;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

my $api = new Flickr::API({'key' => 'made_up_key'});
my $rsp = $api->execute_method('fake.method', {});

ok($rsp->{error_code} == 100); # error code for invalid key

