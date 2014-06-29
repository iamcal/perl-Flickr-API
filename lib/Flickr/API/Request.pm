package Flickr::API::Request;

use strict;
use warnings;
use HTTP::Request;
use URI;
use Encode qw(encode_utf8);

our @ISA = qw(HTTP::Request);
our $VERSION = '0.03';

sub new {
	my $class = shift;
	my $options = shift;
	my $self = HTTP::Request->new;
	$self->{api_method}	= $options->{method};
	$self->{api_args}	= $options->{args};
	$self->{rest_uri}	= $options->{rest_uri} || 'https://api.flickr.com/services/rest/';
	$self->{unicode}	= $options->{unicode} || 0;

	bless $self, $class;

	$self->method('POST');
        $self->uri($self->{rest_uri});

	return $self;
}

sub encode_args {
	my ($self) = @_;

	my $url = URI->new('https:');

	if ($self->{unicode}){
		for my $k(keys %{$self->{api_args}}){
			$self->{api_args}->{$k} = encode_utf8($self->{api_args}->{$k});
		}
	}
	$url->query_form(%{$self->{api_args}});

	my $content = $url->query;

	$self->header('Content-Type' => 'application/x-www-form-urlencoded');
	if (defined($content)) {
		$self->header('Content-Length' => length($content));
		$self->content($content);
	}
}

1;

__END__

=head1 NAME

Flickr::API::Request - A request to the Flickr API

=head1 SYNOPSIS

  use Flickr::API;
  use Flickr::API::Request;

  my $api = Flickr::API->new({'key' => 'your_api_key'});

  my $request = Flickr::API::Request->new({
  	'method' => $method,
  	'args' => {},
  }); 

  my $response = $api->execute_request($request);


=head1 DESCRIPTION

This object encapsulates a request to the Flickr API.

C<Flickr::API::Request> is a subclass of L<HTTP::Request>, so you can access
any of the request parameters and tweak them yourself. The content, content-type
header and content-length header are all built from the 'args' list by the
C<Flickr::API::execute_request()> method.


=head1 AUTHOR

Copyright (C) 2004, Cal Henderson, E<lt>cal@iamcal.comE<gt>


=head1 SEE ALSO

L<Flickr::API>.

=cut
