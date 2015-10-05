package Flickr::Person;

use Flickr::Types qw( Personsearch Personuser);
use Carp;
use Moo;
use namespace::clean;


has api => (
    is  => 'ro',
    isa => sub { confess "$_[0] is not a Flickr::API::People",
                     if (ref($_[0]) ne 'Flickr::API::People');
             },
    required => 1,

);

has searchkey => (
    is   => 'rw',
    isa  => Personsearch,
    required => 1,
);

has user => (
    is => 'rwp',
    isa => Personuser,
);

has success => (
    is      => 'rwp',
    isa     =>  sub { $_[0] != 0 ? 1 : 0; },
    default =>  0,
);



sub BUILD {
    my ($self) = @_;

    $self->search;

    return;
}

sub search {
    my $self = shift;
    my $key = $self->searchkey;
    my $api = $self->api;

    if ( defined ($key->{email})) {

        $api->findByEmail($key->{email});

    }
    elsif (defined ($key->{username})) {

        $api->findByUsername($key->{username});

    }
    else {

        $self->_set_success(0);
        confess "Person->search was handed a non-person key to search for. Understandably upset";
    }

    if (($api->api_success) == 0 ) {

        carp 'Person->search failed. Flickr::API::People reports "',$api->api_message,'"';
        $self->_set_success(0);

    } else {

        $self->_set_success(1);
        $self->_set_user($api->user());
    }
}


sub getGroups {

    my ($self,$args) = @_;

    my $api  = $self->api;
    my $call = {};
    my $groups = {};

    $call->{user_id} = $api->nsid;

    if (defined($args->{user_id})) { $call->{user_id} = $args->{user_id}; }
    if (defined($args->{extras}))  { $call->{extras}  = $args->{extras}; }

    if ($api->perms() =~ /^(read|write|delete)$/) {

        my $rsp = $api->execute_method('flickr.people.getGroups',$call);

        if ($rsp->success == 1) {

            $groups = $rsp->as_hash();
            $self->_set_success(1);

        }
        else {

            carp 'Person->getGroups failed with ',$rsp->message;
            $self->_set_success(0);

        }
    }
    else {

        carp 'Person->getGroups failed. Method needs read permission and api has ',$api->perms();
        $self->_set_success(0);

    }

    return $groups;

}

1;

__END__

=head1 NAME

Flickr::Person - Perl interface to the Flickr API for people

=head1 SYNOPSIS
