use strict;
use warnings;
use Test::More;
use Flickr::API::Reflection;

if (defined($ENV{MAKETEST_OAUTH_CFG})) {
    plan( tests => 9 );
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

    skip "Skipping oauth reflection tests, oauth config isn't there or is not readable", 8
        if $fileflag == 0;

    $api = Flickr::API::Reflection->import_storable_config($config_file);

    isa_ok($api, 'Flickr::API::Reflection');
    is($api->is_oauth, 1, 'Does this Flickr::API::Reflection object identify as OAuth');

    my @methods = $api->methods_list();

    cmp_ok( $#methods, '>', 0,  "Did we get an array of methods");
    cmp_ok( $#methods, '>', -1, "Did we get an array that's initialized");

    my %check = map {$_ => 1} @methods;

    is( $check{'flickr.reflection.getMethods'}, 1, 'Was flickr.reflection.getMethods in the methods_list');
    is( $check{'flickr.reflection.getMethodInfo'}, 1, 'Was flickr.reflection.getMethodInfo in the methods_list');

    my %methods = $api->methods_hash();

    is( $methods{'flickr.reflection.getMethods'}, 1, 'Was flickr.reflection.getMethods in the methods_hash');
    is( $methods{'flickr.reflection.getMethodInfo'}, 1, 'Was flickr.reflection.getMethodInfo in the methods_hash');

}


exit;

__END__


# Local Variables:
# mode: Perl
# End:
