use strict;
use warnings;
use Test::More;
use Flickr::API::People;
use Flickr::Person;

if (defined($ENV{MAKETEST_OAUTH_CFG})) {

    plan( tests => 7 );
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

    skip "Skipping people tests, oauth config isn't there or is not readable", 7   ##############
        if $fileflag == 0;

    $api = Flickr::API::People->import_storable_config($config_file);

    isa_ok($api, 'Flickr::API::People');

    is($api->is_oauth, 1, 'Does this Flickr::API::People object identify as OAuth');
    is($api->api_success,  1, 'Did people api initialize successful');


    my $values_file  = $ENV{MAKETEST_VALUES};

    my $valsflag=0;
    if (-r $values_file) { $valsflag = 1; }
    is($valsflag, 1, "Is the values file: $values_file, readable?");

  SKIP: { 
        skip "Skipping some people tests, values file isn't there or is not readable", 2   ##########
            if $valsflag == 0;

        my %peoplevalues = (
            'search_email' => '',
            'search_user'  => '',
        );

        open my $VALUES, "<", $values_file or die;

        while (<$VALUES>) {

            chomp;
            s/\s+//g;
            my ($key,$val) = split(/=/);
            if (defined($peoplevalues{$key})) { $peoplevalues{$key} = $val; }

        }

        isnt($peoplevalues{'search_email'}, '', 'Is there an email to search for');
        isnt($peoplevalues{'search_user'},  '', 'Is there a userid to search for');

        my $vlad = $api->findByEmail($peoplevalues{'search_email'});
        my $vald = $api->findByUsername($peoplevalues{'search_user'});


    } # vals File

} # oauth config

exit;

__END__


# Local Variables:
# mode: Perl
# End:
