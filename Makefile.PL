use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Flickr::API',
    'VERSION_FROM'	=> 'API.pm',
    'PREREQ_PM'		=> {
		'LWP::UserAgent' => 0,
		'HTTP::Request' => 0,
		'HTTP::Response' => 0,
		'URI' => 0,
		'XML::Parser::Lite::Tree' => 0.03,
	},
);
