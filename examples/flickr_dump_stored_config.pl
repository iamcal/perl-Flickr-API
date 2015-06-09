use warnings;
use strict;
use Data::Dumper;
use Term::ReadKey;
use Term::ReadLine;
use Storable  qw(store_fd retrieve_fd);

my $term = Term::ReadLine->new('Flickr OAuth Configure Dumper');
$term->ornaments(0);

print <<EOT;

Working with (or testing) OAuth authentication in the Flickr API
can be made a little easier by using a configuration stored using
Storable.pm from the Perl core. The Flickr API module API.pm
has two convenience methods oauth_export_storable_config() and
oauth_import_storable_config(). These methods, as their names
imply, allow you to export the oauth portion of an API to a file
or to reconstruct the API by importing a previeously stored
configuration.

This script will dump a configuration made the Flickr::API
oauth_export_storable_config() or by the script: 
examples/make_stored_config.pl

EOT

my $ans = $term->readline('Press [Enter] to continue or Exit to quit:  ');

if ($ans =~ m/^E.*$/i) { exit; }

my $config;
my $cfgfile;
my $loop = 0;

while ($loop == 0) {

	print "\n\n";
	$cfgfile = $term->readline('Enter the complete path and name for your config file:   ');

	open my $CFG, "<", $cfgfile or die "Failed to open  $cfgfile: $!";

    $config = retrieve_fd($CFG);

    close $CFG;
    $loop++;
}


print "\n\nRetrieved\n\n",Dumper($config),"\nfrom ",$cfgfile," using Storable\n\n";

exit;
