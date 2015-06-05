use strict;
use warnings;
use Test::More tests => 18;
use Data::Dumper;
use Storable;

use Flickr::API;

my $in_cfg_file  = $ENV{MAKETEST_OAUTH_CFG};
my $out_cfg_file = $in_cfg_file;
my $in_cfg_ref;

SKIP: {

    skip "Skipping request token tests, oauth config not specified via \$ENV{MAKETEST_OAUTH_CFG}", 18
      if !$in_cfg_file;

    my $fileflag=0;
    if (-r $in_cfg_file) { $fileflag = 1; }
    is($fileflag, 1, "Is the config file: $in_cfg_file, readable?");

  SKIP: {

        skip "Skipping request token tests, oauth config isn't there or is not readable", 17
            if $fileflag == 0;

        $in_cfg_ref = retrieve($in_cfg_file);

	    my $api;

        $api = Flickr::API->new({
								 'consumer_key'    => $in_cfg_ref->{consumer_key},
								 'consumer_secret' => $in_cfg_ref->{consumer_secret},
		    					});

	    isa_ok($api, 'Flickr::API');
	    is($api->is_oauth, 1, 'Does Flickr::API object identify as OAuth');
	    is($api->get_oauth_request_type(), 'consumer', 'Does Flickr::API object identify as consumer request');
	    like($in_cfg_ref->{consumer_key}, qr/[0-9a-f]+/i,
		     "Did we get a hexadecimal consumer key in the config");

	    like($in_cfg_ref->{consumer_secret}, qr/[0-9a-f]+/i,
		     "Did we get a hexadecimal consumer secret in the config");

	    my $request_req = $api->oauth_request_token({'callback' => $in_cfg_ref->{callback}});

	    is($request_req, 'ok', "Did oauth_request_token complete successfully");

	  SKIP: {
			skip "Skipping request token tests, oauth_request_token returns $request_req", 11
			  if $request_req ne 'ok';

			my %config = $api->oauth_export_config();
			$config{'continue-to-access'} = $request_req;

			$fileflag=0;
			if (-w $out_cfg_file) { $fileflag = 1; }
			is($fileflag, 1, "Is the config file: $out_cfg_file, writeable?");

			$api->oauth_export_storable_config($out_cfg_file);

			my $api2 = Flickr::API->oauth_import_storable_config($out_cfg_file);

			isa_ok($api2, 'Flickr::API');

			is_deeply($api2->{oauth}, $api->{oauth}, "Did oauth_import_storable_config get back the config we stored");

			isa_ok($api2->{oauth}->{request_token}, 'Net::OAuth::V1_0A::RequestTokenResponse');
			is($api->{oauth}->{request_token}->{callback_confirmed}, 'true',
			   'Is the callback confirmed in the request token'); #10
			is($api2->{oauth}->{token}, $api2->{oauth}->{request_token}->{token},
			   'Did the request token propagate into the api2');
			is($api2->{oauth}->{token_secret}, $api2->{oauth}->{request_token}->{token_secret},
			   'Did the request token_secret propagate into the api2');
			is($api2->{oauth}->{callback}, $in_cfg_ref->{callback}, 'Did the callback make it into the api2');

			is($api2->{oauth}->{consumer_key}, $in_cfg_ref->{consumer_key},
			   'Did the consumer key save into config file');
			is($api2->{oauth}->{consumer_secret}, $in_cfg_ref->{consumer_secret},
			   'Did the consumer secret save into config file');
			like($api2->{oauth}->{request_token}->{token_secret}, qr/[0-9a-f]+/i,
			'Was a request token received and are we good to go to to access token tests?');
			print Dumper($api2->{oauth});

		}
	}
}

exit;


# Local Variables:
# mode: Perl
# End:
