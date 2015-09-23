package Flickr::Person;

use strict;
use warnings;
use Carp;
use Flickr::API::People;

sub new {
    my $class = shift;
    my $args  = shift;

    my $papi;
    my $user = {};

    my $person={};

    $person->{status}->{success} = 0;
    $person->{status}->{message}  = 'Not Instantiated';

    bless $person, $class;

    if ($args->{api} && ref($args->{api}) eq 'Flickr::API::People') {

        $papi = $args->{api};

    }
    elsif ($args->{configfile}) {

        $papi = Flickr::API::People->import_storable_config($args->{configfile});

    }
    else {

        carp "\nFlickr::Person->new() needs either a Flickr::API::People object\n" .
            "   or a storable config file\n";

        $person->_set_status(0,'No Flickr::API::People or storable config');


    }

    if ($papi->api_success() == 1) {

        if ($args->{findByEmail}) {

            $papi->findByEmail($args->{findByEmail});

            if ($papi->api_success() == 1) {

                $person->_set_status(1,'Found user ' .
                                         $papi->username() .
                                         ' using email ' .
                                         $args->{findByEmail} );

                $person->{user} = $papi->user();
                $person->{api}  = $papi;
            }
            else {

                $person->_set_status(0,'findByEmail failed: ' . $papi->error_message());

            }
        }
        elsif  ($args->{findByUsername}) {

            $papi->findByUsername($args->{findByUsername});

            if ($papi->api_success() == 1) {

                $person->_set_status(1,'Found user ' .
                                         $papi->username() .
                                         ' using username ' .
                                         $args->{findByUsername} );

                $person->{user} = $papi->user();
                $person->{api}  = $papi;

            }
            else {

                $person->_set_status(0,'findByUsername failed: ' . $papi->error_message());

            }

        }
        else {

            carp "\nFlickr::Person->new() needs either an email address or username\n";
            $person->_set_status(0,'Flickr::Person->new() needs either an email address or username');

        }
    } # api successful
    else {

        carp "\nFlickr::Person->new() unsuccessful with Flickr::API::People ";
        $person->_set_status(0,'Flickr::Person->new() unsuccessful with Flickr::API::People');

    } # else api successful

    return $person;

} #new

sub success {

    my $self = shift;
    return $self->{status}->{success};

}
sub message {

    my $self = shift;
    return $self->{status}->{message};

}

sub getGroups {

    my $self = shift;
    my $args = shift;
    if ($self->perms() eq 'none') {

    }
    return;
}

sub getInfo {

    my $self = shift;
    my $args = shift;

    return;
}

sub getLimits {

    my $self = shift;
    my $args = shift;
    if ($self->perms() eq 'none') {

    }
    return;
}

sub getPhotos {

    my $self = shift;
    my $args = shift;

    return;
}

sub getPhotosOf {

    my $self = shift;
    my $args = shift;

    return;
}


sub getPublicGroups {

    my $self = shift;
    my $args = shift;
    if ($self->perms() eq 'none') {

    }
    return;
}


sub getPublicPhotos {

    my $self = shift;
    my $args = shift;
    if ($self->perms() eq 'none') {

    }
    return;
}


sub getUploadStatus {

    my $self = shift;
    my $args = shift;
    if ($self->perms() eq 'none') {

    }
    return;
}

sub _set_status {

    my $self  =  shift;
    my $good  =  shift;
    my $msg   =  shift;

    if ($good != 0) { $good = 1; }

    $self->{status}->{success} = $good;
    $self->{status}->{message} = $msg;

    return;
}

sub _person_only {

    my $self = shift;
    my $copy = $self;
    delete $copy->{api};
    return $copy;

}


1;

__END__

=head1 NAME

Flickr::Person - Perl interface to the Flickr API for people

=head1 SYNOPSIS
