package Flickr::API::Response;

use strict;
use warnings;

our $VERSION = '0.01';

sub new {
	my $class = shift;
	my $self = bless {}, $class;
	my $options = shift;
	$self->{raw} = '';
	$self->{request} = $options->{request};
	$self->{tree} = undef;
	$self->{success} = 0;
	$self->{error_code} = 0;
	$self->{error_message} = '';
	return $self;
}

sub set_fail {
	my ($self, $code, $message) = @_;
	$self->{success} = 0;
	$self->{error_code} = $code;
	$self->{error_message} = $message;
}

sub set_ok {
	my ($self, $tree) = @_;
	$self->{success} = 1;
	$self->{tree} = $tree;
}

1;

__END__

=head1 NAME

Flickr::API::Response - A response from the flickr API.

=head1 SYNOPSIS

  use Flickr::API;


=head1 DESCRIPTION

This object encapsulates a response from the Flickr API. It's
basically a blessed hash with the following structure:

  {
	'request' => Flickr::API::Request,
	'success' => 1,
	'tree' => XML::Parser::Lite::Tree,
	'error_code' => 0,
	'error_message' => '',
  }

The C<request> key contains the request object that this response
was generated from. The C<sucess> key contains 1 or 0, indicating
whether the request suceeded. If it failed, C<error_code> and
C<error_message> explain what went wrong. If it suceeded, C<tree>
contains an C<XML::Parser::Lite::Tree> object of the response XML.


=head1 AUTHOR

Copyright (C) 2004, Cal Henderson, E<lt>cal@iamcal.comE<gt>


=head1 SEE ALSO

L<Flickr::API>
L<XML::Parser::Lite>

=cut

