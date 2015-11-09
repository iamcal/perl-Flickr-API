use strict;
use warnings;
use Test::More;
use Storable;
use Flickr::API;

if (defined($ENV{MAKETEST_OAUTH_CFG})) {
    plan( tests => 16 );
}
else {
    plan(skip_all => 'These tests require that MAKETEST_OAUTH_CFG points to a valid config, see README.');
}



my $config_file  = $ENV{MAKETEST_OAUTH_CFG};
my $config_ref;
my $api;

$api = Flickr::API->new(
    { consumer_key    => '012345beefcafe543210',
      consumer_secret => 'a234b345c456feed',
  }
);


isa_ok($api, 'Flickr::API');


my $suc = $api->api_success;

my $sta = $api->_full_status;

use Data::Dumper::Simple;
warn Dumper($suc,$sta);


my $fileflag=0;
if ($config_file and -r $config_file) { $fileflag = 1; }
is($fileflag, 1, "Is the config file: $config_file, readable?");

SKIP: {

    skip "Skipping authentication tests, oauth config isn't there or is not readable", 15
        if $fileflag == 0;

    $api = Flickr::API->import_storable_config($config_file);

    isa_ok($api, 'Flickr::API');
    is($api->is_oauth, 1, 'Does Flickr::API object identify as OAuth');

    like($api->{oauth}->{consumer_key},  qr/[0-9a-f]+/i, "Did we get a consumer key from $config_file");
    like($api->{oauth}->{consumer_secret}, qr/[0-9a-f]+/i, "Did we get a consumer secret from $config_file");

    like($api->{oauth}->{token}, qr/^[0-9]+-[0-9a-f]+$/i,
         "Did we get an access_token token from $config_file");
    like($api->{oauth}->{token_secret}, qr/^[0-9a-f]+$/i,
         "Did we get an access_token token_secret from $config_file");

    my $proceed = 0;

    if ($api->{oauth}->{token} =~ m/^[0-9]+-[0-9a-f]+$/i and
            $api->{oauth}->{token_secret} =~ m/^[0-9a-f]+$/i) {

        $proceed = 1;
    }

  SKIP: {

        skip "Skipping authentication tests, oauth access token seems wrong", 9
            if $proceed == 0;

        my $rsp = $api->execute_method('flickr.auth.oauth.checkToken');
        my $ref = $rsp->as_hash();

        is($ref->{stat}, 'ok', "Did flickr.auth.oauth.checkToken complete sucessfully");

        isnt($ref->{oauth}->{user}->{nsid}, undef, "Did flickr.auth.oauth.checkToken return nsid");
        isnt($ref->{oauth}->{user}->{username}, undef, "Did flickr.auth.oauth.checkToken return username");

        $rsp = $api->execute_method('flickr.test.login');
        $ref = $rsp->as_hash();

        is($ref->{stat}, 'ok', "Did flickr.test.login complete sucessfully");

        isnt($ref->{user}->{id}, undef, "Did flickr.test.login return id");
        isnt($ref->{user}->{username}, undef, "Did flickr.test.login return username");


        $rsp = $api->execute_method('flickr.prefs.getPrivacy');
        $ref = $rsp->as_hash;

        is($ref->{stat}, 'ok', "Did flickr.prefs.getPrivacy complete sucessfully");

        isnt($ref->{person}->{nsid}, undef, "Did flickr.prefs.getPrivacy return nsid");
        isnt($ref->{person}->{privacy}, undef, "Did flickr.prefs.getPrivacy return privacy");

    }
}


exit;

__END__


# Local Variables:
# mode: Perl
# End:
