use strict;
use warnings;
use Test::More;
use Flickr::API::People;

if (defined($ENV{MAKETEST_OAUTH_CFG})) {
    plan( tests => 4 );
}
else {
    plan(skip_all => 'People tests require that MAKETEST_OAUTH_CFG points to a valid config, see README.');
}

my $config_file  = $ENV{MAKETEST_OAUTH_CFG};
my $config_ref;
my $api;

my $fileflag=0;
if (-r $config_file) { $fileflag = 1; }
is($fileflag, 1, "Is the config file: $config_file, readable?");
SKIP: {

    skip "Skipping people tests, oauth config isn't there or is not readable", 3
        if $fileflag == 0;

    $api = Flickr::API::People->import_storable_config($config_file);

    isa_ok($api, 'Flickr::API::People');

    is($api->is_oauth, 1, 'Does this Flickr::API::People object identify as OAuth');
    is($api->success,  1, 'Did people api initialize successful');



}


exit;

__END__


# Local Variables:
# mode: Perl
# End:
