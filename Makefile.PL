use ExtUtils::MakeMaker;

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
		'Digest::MD5' => 0,
		'Test::More' => 0,
        'Net::OAuth' => 0,
        'String::Random' => 0,
        'Getopt::Long' => 0,
	},
    'EXE_FILES' =>
                [
                'examples/flickr_oauth_authentication.pl',
                'examples/flickr_method_test_echo.pl',
                'examples/flickr_method_test_login.pl',
                ]
);
