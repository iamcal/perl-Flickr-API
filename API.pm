package Flickr::API;

use strict;
use warnings;
use LWP::UserAgent;
use XML::Parser::Lite::Tree;
use Flickr::API::Request;
use Flickr::API::Response;

our $VERSION = '0.01';

sub new {
	my $class = shift;
	my $self = bless {}, $class;
	my $options = shift;
	$self->{key} = $options->{key};
	return $self;
}

sub execute_method {
	my ($self, $method, $args) = @_;

	my $request = new Flickr::API::Request({'method' => $method, 'args' => $args});

	$self->execute_request($request);
}

sub execute_request {
	my ($self, $request) = @_;

	my $response = new Flickr::API::Response({'request' => $request});

	$request->{args}->{method} = $request->{method};
	$request->{args}->{api_key} = $self->{key};

	my $ua = LWP::UserAgent->new;
	my $ua_resp = $ua->post('http://www.flickr.com/services/rest/', $request->{args});

	if ($ua_resp->{_rc} != 200){
		$response->set_fail(0, "API returned a non-200 status code ($ua_resp->{_rc})");
		return $response;
	}

	my $tree = XML::Parser::Lite::Tree::instance()->parse($ua_resp->{_content});

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

  my $api = new Flickr::API({'key' => 'your_api_key'});

  my $rsp = $api->execute_method('flickr.test.echo', {
		'foo' => 'bar',
		'baz' => 'quux',
	});

=head1 DESCRIPTION

A simple interface for using the Flickr API.


=head2 METHODS

=over 4

=item C<execute_method($method, $args)>

Constructs a C<Flickr::API::Request> object and executes it, returning a C<Flickr::API::Response> object.

=item C<execute_request($request)>

Executes a C<Flickr::API::Request> object, returning a C<Flickr::API::Response> object.

=back


=head1 AUTHOR

Copyright (C) 2004, Cal Henderson, E<lt>cal@iamcal.comE<gt>

=head1 SEE ALSO

L<Flickr::API::Request>
L<Flickr::API::Response>
L<XML::Parser::Lite>

=cut
