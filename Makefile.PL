use ExtUtils::MakeMaker;

warn <<EOT;





############################___ NOTICE ___##############################
#                                                                      #
#  Some of the Authentication tests require information from you.      #
#                                                                      #
#  An easy way to assemble this information is to execute the script:  #
#  script/flickr_make_stored_config.pl                                 #
#                                                                      #
#  The script requires --config_out=/the/path/to/where/to/write/config #
#  and can optionally accept arguments for either the Flickr native    #
#  authentication, or the OAuth authentication for FLickr. Minimally   #
#  you need your key/consumer_key and secret/consumer_secret to build  #
#  a usable Flickr/OAuth stored configuration.                         #
#                                                                      #
# If you want to run these tests, answer `No' to the question below    #
# and run the script or build your own config by hand. When you are    #
# ready for "make test" use:                                           #
#    make test MAKETEST_OAUTH_CFG=/the/path/to/above/filename          #
# or                                                                   #
#    make test MAKETEST_FLICKR_CFG=/the/path/to/above/filename         #
# or both.                                                             #
#                                                                      #
############################___ NOTICE ___##############################

EOT
my $ans = prompt('Do you want to continue?', 'yes');
exit 0 unless $ans =~ /^y(es)?\z/i;

WriteMakefile(
    'NAME'		=> 'Flickr::API',
    'VERSION_FROM'	=> 'lib/Flickr/API.pm',
    'LICENSE'           => 'perl',
    'MIN_PERL_VERSION'  => '5.008',
    'META_MERGE'        => {
        resources => {
            repository  =>  'https://github.com/iamcal/perl-Flickr-API',
        },
    },
    'PREREQ_PM'        => {
        'LWP::UserAgent' => 0,
        'HTTP::Request' => 0,
        'HTTP::Response' => 0,
        'HTTP::Message' => 1.56, # first version of libwww that supports decoded_content()
        'URI' => 1.18,
        'XML::Parser::Lite::Tree' => 0.06,
        'XML::LibXML::Simple' => 0,
        'Digest::MD5' => 0,
        'Getopt::Long' => 0,
        'Test::More' => 0,
        'Test::Script' => 0,
        'Net::OAuth' => 0,
    },
    'TEST_REQUIRES'  =>  {
        'Test::Script' => 0,
    },
    'EXE_FILES' =>
        [
            'script/flickr_dump_stored_config.pl',
            'script/flickr_make_stored_config.pl',
        ]
    );
