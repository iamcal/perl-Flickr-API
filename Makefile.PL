use ExtUtils::MakeMaker;

warn <<EOT;



############################___ NOTICE ___##############################
#                                                                      #
#  Some of the OAuth tests require information from you.               #
#                                                                      #
#  An easy way to assemble this information is to execute the script:  #
#  example/flickr_make_stored_config.pl                                #
#  Which (1) prompts you for a filename, consumer_key, consumer_secret,#
#  and callback url; (2) builds a hash with this information; and (3)  #
#  uses Storable to save the hash in a file easily processed by a test #
#  script.                                                             #
#                                                                      #
# If you want to run these tests, answer `No' to the question below    #
# and run the script or build your own config by hand. When you are    #
# ready for "make test" use:                                           #
#    make test MAKETEST_OAUTH_CFG=/the/path/to/above/filename          #
#                                                                      #
############################___ NOTICE ___##############################



EOT
my $ans = prompt('Do you want to continue?', 'yes');
exit 0 unless $ans =~ /^y(es)?\z/i;

WriteMakefile(
    'NAME'		=> 'Flickr::API',
    'VERSION_FROM'	=> 'lib/Flickr/API.pm',
    'LICENSE'           => 'perl',
    'META_MERGE'        => {
        resources => {
            repository  =>  'https://github.com/iamcal/perl-Flickr-API',
        },
    },
    'PREREQ_PM'		=> {
		'LWP::UserAgent' => 0,
		'HTTP::Request' => 0,
		'HTTP::Response' => 0,
		'HTTP::Message' => 1.56, # first version of libwww that supports decoded_content()
		'URI' => 1.18,
		'XML::Parser::Lite::Tree' => 0.06,
		'XML::Simple' => 0,
		'Digest::MD5' => 0,
		'Test::More' => 0,
        'Net::OAuth' => 0,
			   },
			  'TEST_REQUIRES'  =>  {
									'Term::ReadKey' => 0,
									'Getopt::Long' => 0,
								   },
    'EXE_FILES' =>
                [
                'examples/flickr_oauth_authentication.pl',
                'examples/flickr_method_test_echo.pl',
                'examples/flickr_method_test_login.pl',
                'examples/flickr_dump_stored_config.pl',
                'examples/flickr_make_stored_config.pl',
                ]
);
