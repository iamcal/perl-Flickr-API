package Flickr::API::Upload;

use strict;
use warnings;
use HTTP::Request::Common;
use Net::OAuth;
use URI;
use Carp;
use Digest::MD5 qw(md5_hex);
use Encode qw(encode_utf8);

use parent qw(HTTP::Request);

our $VERSION = '1.27_01';


sub new {

    my ($class, $args) = @_;
    my $self;

    my @params = (
        "title",
        "description",
        "tags",
        "is_public",
        "is_friend",
        "is_family",
        "safety_level",
        "content_type",
        "hidden"
    );

    my $photo = {};

    unless ( -f $args->{photo}->{photo} &&  -r $args->{photo}->{photo} ) {

        carp "\nPhoto: ",$args->{photo}->{photo},", is not a readable file.\n";
        return;

    }

    #
    # make hashref of valid arguments for an upload, ignore extraneous
    #
    $photo->{photo} = $args->{photo}->{photo};
    $photo->{async} = $args->{photo}->{async}  || '0';

    for my $param (@params) {

        if (defined($args->{photo}->{$param})) { $photo->{$param} = $args->{photo}->{$param}; }

    }

    chomp $photo->{'description'};
    delete($args->{photo});

    $args->{api}->{request_method} = 'POST'; # required to be POST

    if (($args->{api_type} || '') eq 'oauth') {

        $args->{api}->{extra_params} = $photo;

        $Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;

        my $orequest = Net::OAuth->request('protected resource')->new(%{$args->{api}});
        $orequest->sign();

        my $buzo = $orequest->to_hash();

        my @msgarr;

        for my $param (sort keys %{$buzo}) {
            push(@msgarr,$param);
            push(@msgarr,$buzo->{$param});
        }

        push(@msgarr,'photo');
        push(@msgarr, [$photo->{photo}]);

        $self = POST $args->{api}->{request_url},
            'Content-Type' => 'form-data',
            'Content'      => \@msgarr;



    } # if oauth
    else {

        my $pixfile =  $photo->{photo};
        delete  $photo->{photo};

        $photo->{api_key} = $args->{api}->{api_key};
        $photo->{auth_token}   = $args->{api}->{token};
        my $sig           = $args->{api}->{api_secret};

        foreach my $key (sort {$a cmp $b} keys %{$photo}) {

            my $value = (defined($photo->{$key})) ? $photo->{$key} : "";
            $sig .= $key . $value;
        }

        if ($args->{api}->{unicode}) {

            $photo->{api_sig} =  md5_hex(encode_utf8($sig));

        }
        else {

            $photo->{api_sig} = md5_hex($sig);
        }

        my @msgarr;


        for my $param (sort keys %{$photo}) {
            push(@msgarr,$param);
            push(@msgarr,$photo->{$param});
        }
        push(@msgarr,'photo');
        push(@msgarr, [$pixfile]);

        $self = POST $args->{api}->{request_url},
            'Content-Type' => 'form-data',
            'Content'      => \@msgarr;

    } # else i'm flickr

    bless $self, $class;

    return $self;

}



sub encode_args {
    my ($self) = @_;

    my $content;
    my $url = URI->new('https:');

    if ($self->{unicode}){
        for my $k(keys %{$self->{api_args}}){
            $self->{api_args}->{$k} = encode_utf8($self->{api_args}->{$k});
        }
    }
    $url->query_form(%{$self->{api_args}});
    $content = $url->query;


    $self->header('Content-Type' => 'application/x-www-form-urlencoded');
    if (defined($content)) {
        $self->header('Content-Length' => length($content));
        $self->content($content);
    }
    return;
}

1;

__END__

=head1 NAME

Flickr::API::Request - A request to the Flickr API

=head1 SYNOPSIS

=head2 Using the OAuth form:

  use Flickr::API;
  use Flickr::API::Request;

  my $api = Flickr::API->new({'consumer_key' => 'your_api_key'});

  my $request = Flickr::API::Request->new({
      'method' => $method,
      'args' => {},
  });

  my $response = $api->execute_request($request);

=head2 Using the original Flickr form:

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

OAuth patches and additions provided by Louis B. Moore

=head1 SEE ALSO

L<Flickr::API>.
L<Net::OAuth>,

=cut
