package Flickr::API;

use strict;
use warnings;
use LWP::UserAgent;
use XML::Parser::Lite::Tree;
use Flickr::API::Request;
use Flickr::API::Response;
use Digest::MD5 qw(md5_hex);

our @ISA = qw(LWP::UserAgent);

our $VERSION = '0.04';

sub new {
	my $class = shift;
	my $options = shift;
	my $self = new LWP::UserAgent;
	$self->{api_key} = $options->{key};
	$self->{api_secret} = $options->{secret};
	bless $self, $class;
	return $self;
}

sub sign_args {
	my $self = shift;
	my $args = shift;

	my $sig  = $self->{api_secret};

	foreach my $key (sort {$a cmp $b} keys %{$args}) {
		$sig .= $key . $args->{$key};
	}

	return md5_hex($sig);
}

sub execute_method {
	my ($self, $method, $args) = @_;

	my $request = new Flickr::API::Request({'method' => $method, 'args' => $args});

	$self->execute_request($request);
}

sub execute_request {
	my ($self, $request) = @_;

	$request->{api_args}->{method}  = $request->{api_method};
	$request->{api_args}->{api_key} = $self->{api_key};
	$request->{api_args}->{api_sig} = $self->sign_args($request->{api_args});

	$request->encode_args();

	#print $request->as_string();

	my $response = $self->request($request);
	bless $response, 'Flickr::API::Response';
	$response->init_flickr();

	if ($response->{_rc} != 200){
		$response->set_fail(0, "API returned a non-200 status code ($response->{_rc})");
		return $response;
	}

	my $tree = XML::Parser::Lite::Tree::instance()->parse($response->{_content});

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
		return $child if $child->{type} eq 'tag';
	}
	return {};
}

1;
__END__

=head1 NAME

Flickr::API - Perl interface to the Flickr API

=head1 SYNOPSIS

  use Flickr::API;

  my $api = new Flickr::API({'key'    => 'your_api_key',
                             'secret' => 'your_app_secret'});

  my $response = $api->execute_method('flickr.test.echo', {
		'foo' => 'bar',
		'baz' => 'quux',
	});

or

  use Flickr::API;
  use Flickr::API::Request;

  my $api = new Flickr::API({'key' => 'your_api_key'});

  my $request = new Flickr::API::Request({
		'method' => 'flickr.test.echo',
		'args' => {},
	});

  my $response = $api->execute_request($request);
  

=head1 DESCRIPTION

A simple interface for using the Flickr API.

C<Flickr::API> is a subclass of L<LWP::UserAgent>, so all of the various
proxy, request limits, caching, etc are available.

=head2 METHODS

=over 4

=item C<execute_method($method, $args)>

Constructs a C<Flickr::API::Request> object and executes it, returning a C<Flickr::API::Response> object.

=item C<execute_request($request)>

Executes a C<Flickr::API::Request> object, returning a C<Flickr::API::Response> object.

=back


=head1 AUTHOR

Copyright (C) 2004-2005, Cal Henderson, E<lt>cal@iamcal.comE<gt>

Auth API patches provided by Aaron Straup Cope


=head1 SEE ALSO

L<Flickr::API::Request>,
L<Flickr::API::Response>,
L<XML::Parser::Lite>,
L<http://www.flickr.com/>,
L<http://www.flickr.com/services/api/>

=cut
