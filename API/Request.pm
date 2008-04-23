package Flickr::API::Request;

use strict;
use warnings;

our $VERSION = '0.01';

sub new {
	my $class = shift;
	my $self = bless {}, $class;
	my $options = shift;
	$self->{method} = $options->{method};
	$self->{args} = $options->{args};
	return $self;
}

1;

__END__

=head1 NAME

Flickr::API::Request - A request to the Flickr API

=head1 SYNOPSIS

  use Flickr::API;
  use Flickr::API::Request;

  my $request = new Flickr::API::Request({
  	'method' => $method,
  	'args' => \%args,
  }); 

  $api->execute_request($request);


=head1 DESCRIPTION

This object encapsulates a request to the Flickr API.


=head1 AUTHOR

Copyright (C) 2004, Cal Henderson, E<lt>cal@iamcal.comE<gt>


=head1 SEE ALSO

L<Flickr::API>.

=cut
