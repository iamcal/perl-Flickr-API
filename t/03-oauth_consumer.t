use strict;
use warnings;
use Test::More tests => 10;
use Storable;

use Flickr::API;
use XML::Simple qw(:strict);

BEGIN {

    diag "\n\n";
    diag "   If not running with MAKETEST_OAUTH_CFG defined and pointing to a\n";
	diag "   readable and writeable file containing at least your consumer_key\n";
	diag "   and consumer_secret produced with examples/make_stored_config.pl or\n";
	diag "   equivalent, then tests can't exercise using real Flickr API calls\n\n";

}

my $config_file = $ENV{MAKETEST_OAUTH_CFG};
my $config_ref;

SKIP: {

    skip "Skipping consumer message tests, oauth config not specified via \$ENV{MAKETEST_OAUTH_CFG}", 10
	  if !$config_file;

    my $fileflag=0;
    if (-r $config_file) { $fileflag = 1; }
    is($fileflag, 1, "Is the config file: $config_file, readable?");

    SKIP: {

    skip "Skipping consumer message tests, oauth config isn't there or is not readable", 9
        if $fileflag == 0;

    $config_ref = retrieve($config_file);

	like($config_ref->{consumer_key}, qr/[0-9a-f]+/i,
		 "Did we get a hexadecimal consumer key in the config");

	like($config_ref->{consumer_secret}, qr/[0-9a-f]+/i,
		 "Did we get a hexadecimal consumer secret in the config");

	my $api;
	my $rsp;
	my $ref;
	my $content;

	my $xs = XML::Simple->new(ForceArray => 0);

	$api= Flickr::API->new({
							'consumer_key'    => $config_ref->{consumer_key},
							'consumer_secret' => $config_ref->{consumer_secret},
						   });

	isa_ok($api, 'Flickr::API');
	is($api->is_oauth, 1, 'Does Flickr::API object identify as OAuth');
	is($api->get_oauth_request_type(), 'consumer', 'Does Flickr::API object identify as consumer request');

	$rsp =  $api->execute_method('flickr.test.echo', {format => 'fake'});

  SKIP: {
		skip "skipping error code check, since we couldn't reach the API", 1
		  if $rsp->{_rc} ne '200';
		is($rsp->{error_code}, 111, 'checking the error code for "format not found"');
	}

	$rsp =  $api->execute_method('flickr.reflection.getMethods');
	$content = $rsp->decoded_content();
	$content = $rsp->content() unless defined $content;

	$ref = $xs->XMLin($content,KeyAttr => []);

  SKIP: {
		skip "skipping method call check, since we couldn't reach the API", 1
		  if $rsp->{_rc} ne '200';
		is($ref->{'stat'}, 'ok', 'Check for ok status from flickr.reflection.getMethods');
	}

	undef $rsp;
	undef $ref;

	$rsp =  $api->execute_method('flickr.test.echo', { 'foo' => 'barred' } );
	$content = $rsp->decoded_content();
	$content = $rsp->content() unless defined $content;
	$ref = $xs->XMLin($content,KeyAttr => []);


  SKIP: {
		skip "skipping method call check, since we couldn't reach the API", 2
		  if $rsp->{_rc} ne '200';
		is($ref->{'stat'}, 'ok', 'Check for ok status from flickr.test.echo');
		is($ref->{'foo'}, 'barred', 'Check result from flickr.test.echo');
}
}
}

exit;

# Local Variables:
# mode: Perl
# End:
