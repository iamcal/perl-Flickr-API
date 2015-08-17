package Flickr::API::Cameras;

use strict;
use warnings;
use Carp;

use parent qw( Flickr::API );
our $VERSION = '1.19';


sub _initialize {

    my $self=shift;
    $self->{flickr}->{status}->{_rc} = 0;
    $self->{flickr}->{status}->{success} = 1;  # initialize as successful
    $self->{flickr}->{status}->{error_code} = 0;
    $self->{flickr}->{status}->{error_message} = '';
    return;

}


sub brands_list {

    my $self    = shift;
    my $rsp     = $self->execute_method('flickr.cameras.getBrands');
    my $listref = ();

    if ($rsp->success() == 1) {

        $self->{flickr}->{status}->{_rc}            = $rsp->rc();
        $self->{flickr}->{status}->{success}        = 1;
        $self->{flickr}->{status}->{error_code}     = 0;
        $self->{flickr}->{status}->{error_message} = '';

        foreach my $cam (@{$rsp->as_hash()->{brands}->{brand}}) {

            push (@{$listref},$cam->{name});

        }

    }
    else {


        $self->{flickr}->{status}->{_rc}           = $rsp->rc();
        $self->{flickr}->{status}->{success}       = 0;
        $self->{flickr}->{status}->{error_code}    = $rsp->error_code();
        $self->{flickr}->{status}->{error_message} = $rsp->error_message();

        carp "Flickr::API::Cameras Methods list/hash failed with error code: ",$rsp->error_code()," \n ",
            $rsp->error_message(),"\n";

    }
    return $listref;
}




sub brands_hash {

    my $self      = shift;
    my $arrayref  = $self->brands_list();
    my $hashref;


    if ($arrayref) {

        %{$hashref} = map {$_ => 1} @{$arrayref};

    }
    else {

        $hashref = {};

    }
    return $hashref;
}

sub get_cameras {

    my $self   = shift;
    my $brand  = shift;
    my $rsp    = $self->execute_method('flickr.cameras.getBrandModels',
                                    {'brand' => $brand});
    my $hash = $rsp->as_hash();
    my $AoH  = {};
    my $desc = {};

    my $cam;

    if ($rsp->success() == 1) {

        $self->{flickr}->{status}->{_rc}            = $rsp->rc();
        $self->{flickr}->{status}->{success}        = 1;
        $self->{flickr}->{status}->{error_code}     = 0;
        $self->{flickr}->{status}->{error_message} = '';

        $AoH = $hash->{cameras}->{camera};

        foreach $cam (@{$AoH}) {

            $desc->{$brand}->{$cam->{id}}->{name}    = $cam->{name};
            $desc->{$brand}->{$cam->{id}}->{details} = $cam->{details};
            $desc->{$brand}->{$cam->{id}}->{images}  = $cam->{images};

        }

    }
    else {

        carp "Flickr::API::Cameras get method failed with error code: ",$rsp->error_code()," \n ",
            $rsp->error_message(),"\n";

        $self->{flickr}->{status}->{_rc}           = $rsp->rc();
        $self->{flickr}->{status}->{success}       = 0;
        $self->{flickr}->{status}->{error_code}    = $rsp->error_code();
        $self->{flickr}->{status}->{error_message} = $rsp->error_message();

    }

    return $desc;
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

Flickr::API::Cameras - An interface to the flickr.cameras.* methods.

=head1 SYNOPSIS

  use Flickr::API::Cameras;

  my $api = Flickr::API::Cameras->new({'consumer_key' => 'your_api_key'});

or

  my $api = Flickr::API::Cameras->import_storable_config($config_file);

  my @brands = $api->brands_list();
  my %brands = $api->brands_hash();

  my $cameras = $api->get_cameras($brands[1]);


=head1 DESCRIPTION

This object encapsulates the flickr cameras methods.

C<Flickr::API::Cameras> is a subclass of L<Flickr::API>, so you can access
Flickr's camera information easily.


=head1 SUBROUTINES/METHODS

=over

=item C<brands_list>

Returns an array of camera brands from Flickr's API.

=item C<brands_hash>

Returns a hash of camera brands from Flickr's API.


=item C<get_cameras>

Returns a hash reference to the descriptions of the cameras
for a particular brand.

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

=head1 SEE ALSO

L<Flickr::API>.
L<Flickr|http://www.flickr.com/>,
L<http://www.flickr.com/services/api/>
L<https://github.com/iamcal/perl-Flickr-API>


=cut
