package Flickr::Tools;

use strict;
use warnings;
use Carp;
use Storable qw(store_fd retrieve_fd);

our $VERSION = '1.18';



sub new {

    my $class = shift;
    my $self = {};

    $self->{Tools} = $VERSION;

    bless $self, $class;

    return $self;
}



1;

__END__

=head1 NAME

Flickr::Tools - Tools to assist using the Flickr API

=head1 SYNOPSIS

This is a place holder for some configuration and persistence methods
needed a little bit further down the line.

=head1 LICENSE AND COPYRIGHT


Copyright (C) 2014-2015 Louis B. Moore <lbmoore@cpan.org>


This program is released under the Artistic License 2.0 by The Perl Foundation.

=head1 SEE ALSO

L<Flickr|http://www.flickr.com/>,
L<http://www.flickr.com/services/api/>
L<https://www.flickr.com/services/api/auth.oauth.html>
L<https://github.com/iamcal/perl-Flickr-API>

=cut
