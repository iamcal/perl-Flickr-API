package Flickr::API::People;

use strict;
use warnings;
use Carp;
use Flickr::Tools;

use parent qw( Flickr::API );
our $VERSION = '1.18';


sub _initialize {

    my $self=shift;
    $self->{flickr}->{status}->{_rc} = 0;
    $self->{flickr}->{status}->{success} = 1;  # initialize as successful
    $self->{flickr}->{status}->{error_code} = 0;
    $self->{flickr}->{status}->{error_message} = '';
    return;

}

sub error_code {

    my $self = shift;
    return $self->{flickr}->{status}->{error_code};

}

sub error_message {

    my $self = shift;
    my $text = $self->{flickr}->{status}->{error_message};
    $text =~ s/\&quot;/\"/g;
    return $text;

}

sub rc {

    my $self = shift;
    return $self->{flickr}->{status}->{_rc};

}

sub success {

    my $self = shift;
    return $self->{flickr}->{status}->{success};

}

1;

__END__


=head1 NAME

Flickr::API::People - Perl interface to the Flickr API's flickr.people.* methods.

=head1 SYNOPSIS

  use Flickr::API::People;

  my $api = Flickr::API::People->new({'consumer_key' => 'your_api_key'});

or

  my $api = Flickr::API::People->import_storable_config($config_file);


=head1 DESCRIPTION

This object encapsulates the flickr people methods.

C<Flickr::API::People> is a subclass of L<Flickr::API>, so you can access
Flickr's people information easily.


=head1 SUBROUTINES/METHODS

=over

=item C<error_code()>

Returns the Flickr Error Code, if any

=item C<error_message()>

Returns the Flickr Error Message, if any

=item C<success()>

Returns the success or lack thereof from Flickr

=item C<rc()>

Returns the Flickr http status code

=back


=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015, Louis B. Moore

This program is released under the Artistic License 2.0 by The Perl Foundation.

Original version was Copyright (C) 2005 Nuno Nunes, C<< <nfmnunes@cpan.org> >>
This version is much changed and built on the FLickr::API as it appears in
2015. Many thanks to Nuno Nunes for getting this ball rolling.

=head1 SEE ALSO

L<Flickr::API>.
L<Flickr|http://www.flickr.com/>,
L<http://www.flickr.com/services/api/>
L<https://github.com/iamcal/perl-Flickr-API>


=cut
