use strict;
use warnings;
use Test::More;
use Flickr::API::Reflection;

if (defined($ENV{MAKETEST_OAUTH_CFG})) {
    plan( tests => 14 );
}
else {
    plan(skip_all => 'Reflection tests require that MAKETEST_OAUTH_CFG points to a valid config, see README.');
}

my $config_file  = $ENV{MAKETEST_OAUTH_CFG};
my $config_ref;
my $api;

my $fileflag=0;
if (-r $config_file) { $fileflag = 1; }
is($fileflag, 1, "Is the config file: $config_file, readable?");

SKIP: {

    skip "Skipping oauth reflection tests, oauth config isn't there or is not readable", 13
        if $fileflag == 0;

    $api = Flickr::API::Reflection->import_storable_config($config_file);

    isa_ok($api, 'Flickr::API::Reflection');
    is($api->is_oauth, 1, 'Does this Flickr::API::Reflection object identify as OAuth');
    is($api->success,  1, 'Did reflection api initialize successful');

    my $methods = $api->methods_list();

  SKIP: {

        skip "Skipping methods_list tests, not able to reach the API or received error", 3,
            if !$api->success;

        like($methods->[0], qr/^flickr\.[a-z]+\.[a-zA-Z]+$/, "Does the list appear to have a method");

        my %check = map {$_ => 1} @{$methods};

        is( $check{'flickr.reflection.getMethods'}, 1, 'Was flickr.reflection.getMethods in the methods_list');
        is( $check{'flickr.reflection.getMethodInfo'}, 1, 'Was flickr.reflection.getMethodInfo in the methods_list');

    }

    my $hashmethods = $api->methods_hash();

  SKIP: {

        skip "Skipping methods_hash tests, not able to reach the API or received error", 2,
            if !$api->success;

        is( $hashmethods->{'flickr.reflection.getMethods'}, 1,
            'Was flickr.reflection.getMethods in the methods_hash');
        is( $hashmethods->{'flickr.reflection.getMethodInfo'}, 1,
            'Was flickr.reflection.getMethodInfo in the methods_hash');

    }

    my $meth = $api->get_method('flickr.replection.getMethodInfo');

    is( $api->success, 0, 'Did we fail on a fake method as expected');
    is( $api->error_code, 1, 'Did we get an error code from Flickr');

    $meth = $api->get_method('flickr.people.getLimits');

    is( $api->success, 1, 'Was flickr.people.getLimits successful as expected');

    $meth = $api->get_method('flickr.reflection.getMethodInfo');

    is( $api->success, 1, 'Were we successful as expected');
    is( $meth->{'flickr.reflection.getMethodInfo'}->{argument}->{api_key}->{optional}, 0,
        'Did get method reflect that api_key argument is not optional');



}


exit;

__END__


# Local Variables:
# mode: Perl
# End:
