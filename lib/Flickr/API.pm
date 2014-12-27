package Flickr::API;

use strict;
use warnings;
use LWP::UserAgent;
use XML::Parser::Lite::Tree;
use Flickr::API::Request;
use Flickr::API::Response;
use Digest::MD5 qw(md5_hex);
use Scalar::Util qw(blessed);
use Encode qw(encode_utf8);

our @ISA = qw(LWP::UserAgent);

our $VERSION = '1.10';

sub new {
	my $class = shift;
	my $options = shift;

	my $self;
	if ($options->{lwpobj}){
		my $lwpobj = $options->{lwpobj};
		if (defined($lwpobj)){
			my $lwpobjtype = Scalar::Util::blessed($lwpobj);
			if (defined($lwpobjtype)){
				$self = $lwpobj;
				@ISA = ($lwpobjtype);
			}
		}
	}
	$self = LWP::UserAgent->new unless $self;

	$self->{api_key}	= $options->{key};
	$self->{api_secret}	= $options->{secret};
	$self->{rest_uri}	= $options->{rest_uri} || 'https://api.flickr.com/services/rest/';
	$self->{auth_uri}	= $options->{auth_uri} || 'https://api.flickr.com/services/auth/';
	$self->{unicode}	= $options->{unicode} || 0;

	eval {
		require Compress::Zlib;

		$self->default_header('Accept-Encoding' => 'gzip');
	};

	warn "You must pass an API key to the constructor" unless defined $self->{api_key};

	bless $self, $class;
	return $self;
}

sub sign_args {
	my $self = shift;
	my $args = shift;

	my $sig  = $self->{api_secret};

	foreach my $key (sort {$a cmp $b} keys %{$args}) {

		my $value = (defined($args->{$key})) ? $args->{$key} : "";
		$sig .= $key . $value;
	}

	return md5_hex(encode_utf8($sig)) if $self->{unicode};
	return md5_hex($sig);
}

sub request_auth_url {
	my $self  = shift;
	my $perms = shift;
	my $frob  = shift;

	return undef unless defined $self->{api_secret} && length $self->{api_secret};

	my %args = (
		'api_key' => $self->{api_key},
		'perms'   => $perms
	);

	if ($frob) {
		$args{frob} = $frob;
	}

	my $sig = $self->sign_args(\%args);
	$args{api_sig} = $sig;

	my $uri = URI->new($self->{auth_uri});
	$uri->query_form(%args);

	return $uri;
}

sub execute_method {
	my ($self, $method, $args) = @_;

	my $request = Flickr::API::Request->new({
		'method'	=> $method,
		'args'		=> $args,
		'rest_uri'	=> $self->{rest_uri},
		'unicode'	=> $self->{unicode},
	});

	$self->execute_request($request);
}

sub execute_request {
	my ($self, $request) = @_;

	$request->{api_args}->{method}  = $request->{api_method};
	$request->{api_args}->{api_key} = $self->{api_key};

	if (defined($self->{api_secret}) && length($self->{api_secret})){

		$request->{api_args}->{api_sig} = $self->sign_args($request->{api_args});
	}

	$request->encode_args();


	my $response = $self->request($request);
	bless $response, 'Flickr::API::Response';
	$response->init_flickr();

	if ($response->{_rc} != 200){
		$response->set_fail(0, "API returned a non-200 status code ($response->{_rc})");
		return $response;
	}

	my $content = $response->decoded_content();
	$content = $response->content() unless defined $content;

	my $tree = XML::Parser::Lite::Tree::instance()->parse($content);

	my $rsp_node = $self->_find_tag($tree->{children});

	if ($rsp_node->{name} ne 'rsp'){
		$response->set_fail(0, "API returned an invalid response");
		return $response;
	}

	if ($rsp_node->{attributes}->{stat} eq 'fail'){
		my $fail_node = $self->_find_tag($rsp_node->{children});
		if ($fail_node->{name} eq 'err'){
			$response->set_fail($fail_node->{attributes}->{code}, $fail_node->{attributes}->{msg});
		}else{
			$response->set_fail(0, "Method failed but returned no error code");
		}
		return $response;
	}

	if ($rsp_node->{attributes}->{stat} eq 'ok'){
		$response->set_ok($rsp_node);
		return $response;
	}

	$response->set_fail(0, "API returned an invalid status code");
	return $response;
}

sub _find_tag {
	my ($self, $children) = @_;
	for my $child(@{$children}){
		return $child if $child->{type} eq 'element';
	}
	return {};
}

1;
__END__

=head1 NAME

Flickr::API - Perl interface to the Flickr API

=head1 SYNOPSIS

  use Flickr::API;

  my $api = Flickr::API->new({
		'key'    => 'your_api_key',
		'secret' => 'your_app_secret',
		'unicode'=> 0,
	});

  my $response = $api->execute_method('flickr.test.echo', {
		'foo' => 'bar',
		'baz' => 'quux',
	});

or

  use Flickr::API;
  use Flickr::API::Request;

  my $api = Flickr::API->new({'key' => 'your_api_key'});

  my $request = Flickr::API::Request->new({
		'method' => 'flickr.test.echo',
		'args' => {},
	});

  my $response = $api->execute_request($request);
  

=head1 DESCRIPTION

A simple interface for using the Flickr API.

C<Flickr::API> is a subclass of L<LWP::UserAgent>, so all of the various
proxy, request limits, caching, etc are available.

=head1 METHODS

=over

=item C<new({ opt =E<gt> 'value', ... })>

Returns as new L<Flickr::API> object. The options are as follows:

=over

=item C<key> (required)

Your API key

=item C<secret>

Your API key's secret

=item C<rest_uri> & C<auth_uri>

Override the URIs used for contacting the API.

=item C<lwpobj>

Base the C<Flickr::API> on this object, instead of creating a new instance of L<LWP::UserAgent>.
This is useful for using the features of e.g. L<LWP::UserAgent::Cached>.

=item C<unicode>

This flag controls whether Flicrk::API expects you to pass UTF-8 bytes (unicode=0, the default) or
actual unicode strings (unicode=1) in the request.

=back

=item C<execute_method($method, $args)>

Constructs a L<Flickr::API::Request> object and executes it, returning a L<Flickr::API::Response> object.

=item C<execute_request($request)>

Executes a L<Flickr::API::Request> object, returning a L<Flickr::API::Response> object. Calls are signed
if a secret was specified when creating the L<Flickr::API> object.

=item C<request_auth_url($perms,$frob)>

Returns a L<URI> object representing the URL that an application must redirect a user to for approving
an authentication token.

For web-based applications I<$frob> is an optional parameter.

Returns undef if a secret was not specified when creating the C<Flickr::API> object.

=back

=head1 AUTHOR

Copyright (C) 2004-2013, Cal Henderson, E<lt>cal@iamcal.comE<gt>

Auth API patches provided by Aaron Straup Cope

Subclassing patch from AHP


=head1 SEE ALSO

L<Flickr::API::Request>,
L<Flickr::API::Response>,
L<XML::Parser::Lite>,
L<http://www.flickr.com/>,
L<http://www.flickr.com/services/api/>
L<https://github.com/iamcal/perl-Flickr-API>

=cut
