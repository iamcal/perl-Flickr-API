use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Flickr::API',
    'VERSION_FROM'	=> 'lib/Flickr/API.pm',
    'PREREQ_PM'		=> {
		'LWP::UserAgent' => 0,
		'HTTP::Request' => 0,
		'HTTP::Response' => 0,
		'URI' => 1.18,
		'XML::Parser::Lite::Tree' => 0.03,
		'Digest::MD5' => 0,
		'Test::More' => 0,
	},
);
