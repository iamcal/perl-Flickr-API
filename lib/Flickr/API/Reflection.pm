package Flickr::API::Reflection;

use strict;
use warnings;
use Carp;

use parent qw( Flickr::API );
our $VERSION = '1.17';


sub _initialize {

    my $self=shift;
    $self->{flickr}->{status}->{_rc} = 0;
    $self->{flickr}->{status}->{success} = 1;  # initialize as successful
    $self->{flickr}->{status}->{error_code} = 0;
    $self->{flickr}->{status}->{error_message} = '';
    return;

}


sub methods_list {

    my $self    = shift;
    my $rsp = $self->execute_method('flickr.reflection.getMethods');

    if ($rsp->success() == 1) {

        $self->{flickr}->{status}->{_rc}            = $rsp->rc();
        $self->{flickr}->{status}->{success}        = 1;
        $self->{flickr}->{status}->{error_code}     = 0;
        $self->{flickr}->{status}->{error_message} = '';

        return $rsp->as_hash()->{methods}->{method};

    }
    else {


        $self->{flickr}->{status}->{_rc}           = $rsp->rc();
        $self->{flickr}->{status}->{success}       = 0;
        $self->{flickr}->{status}->{error_code}    = $rsp->error_code();
        $self->{flickr}->{status}->{error_message} = $rsp->error_message();

        carp "Flickr::API::Reflection Methods list/hash failed with error code: ",$rsp->error_code()," \n ",
            $rsp->error_message(),"\n";

        my $listref = ();
        return $listref;
    }
}




sub methods_hash {

    my $self      = shift;
    my $arrayref  = $self->methods_list();
    my $hashref;


    if ($arrayref) {

        %{$hashref} = map {$_ => 1} @{$arrayref};

    }
    else {

        $hashref = {};

    }
    return $hashref;
}


sub get_method {

    my $self   = shift;
    my $method = shift;
    my $rsp = $self->execute_method('flickr.reflection.getMethodInfo',
                                    {'method_name' => $method});
    my $hash = $rsp->as_hash();
    my $desc = {};

    my $err;
    my $arg;

    if ($rsp->success() == 1) {

        $self->{flickr}->{status}->{_rc}            = $rsp->rc();
        $self->{flickr}->{status}->{success}        = 1;
        $self->{flickr}->{status}->{error_code}     = 0;
        $self->{flickr}->{status}->{error_message} = '';

        $desc->{$method} = $hash->{method};

        foreach $err (@{$hash->{errors}->{error}}) {

            $desc->{$method}->{error}->{$err->{code}}->{message} = $err->{message};
            $desc->{$method}->{error}->{$err->{code}}->{content} = $err->{content};

        }

        foreach $arg (@{$hash->{arguments}->{argument}}) {

            $desc->{$method}->{argument}->{$arg->{name}}->{optional} = $arg->{optional};
            $desc->{$method}->{argument}->{$arg->{name}}->{content}  = $arg->{content};

        }
    }
    else {

        carp "Flickr::API::Reflection get method failed with error code: ",$rsp->error_code()," \n ",
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

Flickr::API::Reflection - An interface to the flickr.reflection.* methods.

=head1 SYNOPSIS

  use Flickr::API::Reflection;

  my $api = Flickr::API::Reflection->new({'consumer_key' => 'your_api_key'});

or

  my $api = Flickr::API::Reflection->import_storable_config($config_file);

  my @methods = $api->methods_list();
  my %methods = $api->methods_hash();

  my $method = $api->get_method('flickr.reflection.getMethodInfo');


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
=item C<error_code()>

Returns the Flickr Error Code, if any

=item C<error_message()>

Returns the Flickr Error Message, if any

=item C<success()>

Returns the success or lack thereof from Flickr

=item C<rc()>

Returns the Flickr return code

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
