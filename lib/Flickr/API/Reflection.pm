package Flickr::API::Reflection;

use strict;
use warnings;

use parent qw( Flickr::API );
our $VERSION = '1.17';


sub _initialize {

    my $self=shift;
    return;

}


sub methods_list {

    my $self = shift;
    my $rsp = $self->execute_method('flickr.reflection.getMethods');
    my @methods = @{$rsp->as_hash()->{methods}->{method}};
    return @methods;

}

sub methods_hash {

    my $self = shift;
    my @methods = $self->methods_list();
    my %methods = map {$_ => 1} @methods;
    return %methods;

}

sub get_method {
    my $self   = shift;
    my $method = shift;
    return;
}

1;

__END__


=head1 NAME

Flickr::API::Reflection - An interface to the flickr.reflection.* methods.

=head1 SYNOPSIS

  use Flickr::API::Reflection;

  my $api = Flickr::API::Reflection->new({'consumer_key' => 'your_api_key'});

or

  my $api = Flickr::API::Reflection->import_storable_config($config_file);

  my @methods = $api->methods_list();
  my %methods = $api->methods_hash();


=head1 DESCRIPTION

This object encapsulates the flickr reflection methods.

C<Flickr::API::Reflection> is a subclass of L<Flickr::API>, so you can access
all of Flickr's reflection goodness while ignoring the nitty-gritty of setting
up the conversation.


=head1 SUBROUTINES/METHODS

=over

=item C<methods_list>

Returns an array of Flickr's API methods.

=item C<methods_hash>

Returns a hash of Flickr's API methods.


=item C<get_method>

Stub

=back


=head1 LICENSE AND COPYRIGHT

Copyright (C) 2015, Louis B. Moore

This program is released under the Artistic License 2.0 by The Perl Foundation.

=head1 SEE ALSO

L<Flickr::API>.
L<Flickr|http://www.flickr.com/>,
L<http://www.flickr.com/services/api/>
L<https://github.com/iamcal/perl-Flickr-API>


=cut
