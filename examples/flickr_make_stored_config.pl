use warnings;
use strict;
use Data::Dumper;
use Term::ReadKey;
use Term::ReadLine;
use Storable;

my $term = Term::ReadLine->new('Flickr OAuth Configurer');
$term->ornaments(0);

print <<EOT;


Testing OAuth authentication needs input from you to test. This script
asks you for:

1. A full path for the file to hold some configuration information;

2. Your OAuth consumer_key which is also called the Flickr API key;

3. Your OAuth consumer_secret which is also called the Flickr API 
   secret; and

4. optionally, the callback url that Flickr should redirect the
   access_token and token_secret to. It defaults to 
   https://127.0.0.1/

The script will use Storeable to write this configuration information
for use in the OAuth tests in the Flickr::API.

When you "make test" add the environment variable MAKETEST_OAUTH_CFG
pointing to the configuration file you specified. The command should 
look something like:

make test MAKETEST_OAUTH_CFG=/home/myusername/test-flickr-oauth.cfg

 
EOT

my $ans = $term->readline('Press [Enter] to continue or Exit to quit:  ');

if ($ans =~ m/^E.*$/i) { exit; }

my $config = {};
my $cfgfile;
my $loop = 0;

while ($loop == 0) {

	print "\n\n";
	$cfgfile = $term->readline('Enter the complete path and name for your config file:   ');

	unless (-e $cfgfile) {

		open my $CFG, ">", $cfgfile or die "Failed to write to $cfgfile: $!";

		print $CFG "oauth test config\n";

		close $CFG;

	}

	if (-e $cfgfile and -w $cfgfile) {
		$loop++;
	}
	else {
		die "\nProblem creating or writing to $cfgfile\n";
	}

}

$loop = 0;


while ($loop == 0) {

	print "\n";
	$config->{'consumer_key'} = $term->readline('Enter your consumer key (also called api key):   ');

	if ($config->{'consumer_key'} =~ m/^[0-9a-f]+$/i) {

		print "\nconsumer_key: ",$config->{'consumer_key'}," accepted\n";
		$loop++

	}
	else {

		print "\nconsumer_key: ",$config->{'consumer_key'},"is not a hex number\n";

	}
}



$loop=0;

while ($loop == 0) {

	print "\n";
	$config->{'consumer_secret'} = $term->readline('Enter your consumer secret (also called api secret):   ');

	if ($config->{'consumer_secret'} =~ m/^[0-9a-f]+$/i) {

		print "\nconsumer_secret: ",$config->{'consumer_secret'}," accepted\n";
		$loop++

	}
	else {

		print "\nconsumer_secret: ",$config->{'consumer_secret'},"is not a hex number\n";

	}
}


$loop=0;

while ($loop == 0) {

	print "\n";
	my $callback = $term->readline("Enter the callback url (or [Enter] for 'https://127.0.0.1/'): ");

	if (!$callback) { $callback = 'https://127.0.0.1/'; }


	my $check = $term->readline("Use $callback for your callback URL? [NO]: ");

	if ($check =~ m/^y.*$/i) {

		$config->{'callback'} = $callback;
		$loop++

	}
	else {

		print "\nTry again.\n";

	}
}

print "\n\nSaving\n\n",Dumper($config),"\nin ",$cfgfile," using Storable\n\n";

store $config, $cfgfile;

exit;
