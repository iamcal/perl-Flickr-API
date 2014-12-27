package Flickr::API;

use strict;
use warnings;
use LWP::UserAgent;
use XML::Parser::Lite::Tree;
use Flickr::API::Request;
use Flickr::API::Response;
use Net::OAuth;
use String::Random;
use Digest::MD5 qw(md5_hex);
use Scalar::Util qw(blessed);
use Encode qw(encode_utf8);
use Carp;

our @ISA = qw(LWP::UserAgent);

our $VERSION = '1.11';

sub new {
	my $class = shift;
	my $options = shift;

	my $self;
	if ($options->{lwpobj}){
		my $lwpobj = $options->{lwpobj};
		if (defined($lwpobj)){
			my $lwpobjtype = Scalar::Util::blessed($lwpobj);
			if (defined($lwpobjtype)){
				$self = $lwpobj;
				@ISA = ($lwpobjtype);
			}
		}
	}
	$self = LWP::UserAgent->new unless $self;

	if (defined($options->{consumer_key})) {

		$self->{api_type} = 'oauth';
		$self->{rest_uri} = $options->{rest_uri} || 'https://api.flickr.com/services/rest/';
		$self->{auth_uri} = $options->{auth_uri} || 'https://api.flickr.com/services/oauth/authorize';

		if (defined($options->{consumer_secret})) {

			$self->{oauth_request}   = 'consumer';
			$self->{consumer_key}    = $options->{consumer_key};
			$self->{consumer_secret} = $options->{consumer_secret};
			$self->{unicode}         = $options->{unicode}           || 0;

			$self->{oauth}->{consumer_key}     = $options->{consumer_key};
			$self->{oauth}->{consumer_secret}  = $options->{consumer_secret};
			$self->{oauth}->{nonce}            = $options->{nonce}             || _make_nonce();
			$self->{oauth}->{request_method}   = $options->{request_method}    || 'GET';
			$self->{oauth}->{signature_method} = $options->{signature_method}  ||'HMAC-SHA1';
			$self->{oauth}->{timestamp}        = $options->{timestamp}         || time;
			$self->{oauth}->{request_url}      = $self->{rest_uri};
			$self->{oauth}->{version}          = '1.0';

		}
		else {

			carp "OAuth calls must have at least a consumer_key and a consumer_secret";

		}

		if (defined($options->{token}) && defined($options->{token_secret})) {

			$self->{oauth_request}         = 'protected resource';
			$self->{oauth}->{token}        = $options->{token};
			$self->{oauth}->{token_secret} = $options->{token_secret};

		}
	}

	else {

		$self->{api_type}   = 'flickr';
		$self->{api_key}    = $options->{key};
		$self->{api_secret} = $options->{secret};
		$self->{rest_uri}   = $options->{rest_uri} || 'https://api.flickr.com/services/rest/';
		$self->{auth_uri}   = $options->{auth_uri} || 'https://api.flickr.com/services/auth/';
		$self->{unicode}    = $options->{unicode}  || 0;

		carp "You must pass an API key or a Consumer key to the constructor" unless defined $self->{api_key};

	}

	eval {
		require Compress::Zlib;

		$self->default_header('Accept-Encoding' => 'gzip');
	};

	bless $self, $class;
	return $self;
}

sub sign_args {
	my $self = shift;
	my $args = shift;

	if ($self->is_oauth) {

		carp "sign_args called for an OAuth instantiated Flickr::API";
		return undef;

	}

	my $sig  = $self->{api_secret};

	foreach my $key (sort {$a cmp $b} keys %{$args}) {

		my $value = (defined($args->{$key})) ? $args->{$key} : "";
		$sig .= $key . $value;
	}

	return md5_hex(encode_utf8($sig)) if $self->{unicode};
	return md5_hex($sig);
}

sub request_auth_url {
	my $self  = shift;
	my $perms = shift;
	my $frob  = shift;

	if ($self->is_oauth) {

		carp "request_auth_url called for an OAuth instantiated Flickr::API";
		return;

	}

	return undef unless defined $self->{api_secret} && length $self->{api_secret};

	my %args = (
		'api_key' => $self->{api_key},
		'perms'   => $perms
	);

	if ($frob) {
		$args{frob} = $frob;
	}

	my $sig = $self->sign_args(\%args);
	$args{api_sig} = $sig;

	my $uri = URI->new($self->{auth_uri});
	$uri->query_form(%args);

	return $uri;
}

sub execute_method {
	my ($self, $method, $args) = @_;
	my $request;

    if ($self->is_oauth) {

		#
		# Consumer Request Params
		#
		my $oauth = {};

		$oauth->{nonce}                   = _make_nonce();
		$oauth->{consumer_key}            =  $self->{oauth}->{consumer_key};
		$oauth->{consumer_secret}         =  $self->{oauth}->{consumer_secret};
		$oauth->{timestamp}               =  time;
		$oauth->{signature_method}        =  $self->{oauth}->{signature_method};
		$oauth->{version}                 =  $self->{oauth}->{version};

		$oauth->{extra_params} = $args;
		$oauth->{extra_params}->{method}  =  $method;

		#
		# Protected resource params
		#
		if (defined($self->{oauth}->{token})) {

			$oauth->{token}             = $self->{oauth}->{token};
			$oauth->{token_secret}      = $self->{oauth}->{token_secret};

		}

		$request = Flickr::API::Request->new({
											  'api_type'  => 'oauth',
											  'args'      => $oauth,
											  'rest_uri'  => $self->{rest_uri},
											  'unicode'   => $self->{unicode},
											  });
	}
    else {

	    $request = Flickr::API::Request->new({
											  'api_type' => 'flickr',
											  'method'   => $method,
											  'args'     => $args,
											  'rest_uri' => $self->{rest_uri},
											  'unicode'  => $self->{unicode},
											 });
    }

	return $self->execute_request($request);

}


sub execute_request {
	my ($self, $request) = @_;

	$request->{api_args}->{method}  = $request->{api_method};

	unless ($self->is_oauth) { $request->{api_args}->{api_key} = $self->{api_key}; }

	if (defined($self->{api_secret}) && length($self->{api_secret})) {

	   unless ($self->is_oauth) { $request->{api_args}->{api_sig} = $self->sign_args($request->{api_args}); }

	}

	unless ($self->is_oauth) { $request->encode_args(); }

	my $response = $self->request($request);
	bless $response, 'Flickr::API::Response';

	$response->init_flickr();

	if ($response->{_rc} != 200){
		$response->set_fail(0, "API returned a non-200 status code ($response->{_rc})");
		return $response;
	}

	my $content = $response->decoded_content();
	$content = $response->content() unless defined $content;

	my $tree = XML::Parser::Lite::Tree::instance()->parse($content);

	my $rsp_node = $self->_find_tag($tree->{children});

	if ($rsp_node->{name} ne 'rsp'){
		$response->set_fail(0, "API returned an invalid response");
		return $response;
	}

	if ($rsp_node->{attributes}->{stat} eq 'fail'){
		my $fail_node = $self->_find_tag($rsp_node->{children});
		if ($fail_node->{name} eq 'err'){
			$response->set_fail($fail_node->{attributes}->{code}, $fail_node->{attributes}->{msg});
		}else{
			$response->set_fail(0, "Method failed but returned no error code");
		}
		return $response;
	}

	if ($rsp_node->{attributes}->{stat} eq 'ok'){
		$response->set_ok($rsp_node);
		return $response;
	}

	$response->set_fail(0, "API returned an invalid status code");
	return $response;
}

#
# OAuth methods
#

sub oauth_request_token {

	my $self    = shift;
	my $options = shift;
	my %args    = %{$self->{oauth}};

	unless ($self->is_oauth) { carp "oauth_request_token called for Non-OAuth FLickr::API object"; }

	$self->{oauth_request} = 'Request Token';
	$args{request_url}     = $options->{request_token_url} || 'https://api.flickr.com/services/oauth/request_token';
	$args{callback}        = $options->{callback} || 'http:127.0.0.1';

	$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;

	my $request = Net::OAuth->request('Request Token')->new(%args);

	$request->sign;

	my $response = $self->get($request->to_url);

	my $content  = $response->decoded_content();
	$content = $response->content() unless defined $content;

	$self->{oauth}->{request_token} = Net::OAuth->response('request token')->from_post_body($content);
	$self->{oauth}->{token}         = $self->{oauth}->{request_token}->token();
	$self->{oauth}->{token_secret}  = $self->{oauth}->{request_token}->token_secret();
	$self->{oauth}->{callback}      = $args{callback};

	return;

}

sub oauth_authorize_uri {

	my $self    = shift;
	my $options = shift;

	unless ($self->is_oauth) { carp "oauth_authorize_uri called for Non-OAuth FLickr::API object"; }

	my %args    = %{$self->{oauth}};

	$self->{oauth_request} = 'User Authentication';
	$args{perms}           = $options->{perms} || 'read';

	$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;

	return $self->{auth_uri} .
	  '?oauth_token=' . $args{'request_token'}{'token'} .
	  '&perms=' . $args{'perms'};

}

sub oauth_access_token {

	my $self    = shift;
	my $options = shift;

	unless ($self->is_oauth) { carp "oauth_access_token called for Non-OAuth FLickr::API object"; }

	if ($self->{oauth}->{token} ne $options->{token}) {

		carp "Request token in API does not match token for access token request";

	}
	$self->{oauth}->{verifier} = $options->{verifier};

	my %args   = %{$self->{oauth}};

	$args{request_url} = $options->{access_token_url} || 'https://api.flickr.com/services/oauth/access_token';

	$Net::OAuth::PROTOCOL_VERSION = Net::OAuth::PROTOCOL_VERSION_1_0A;

	my $request = Net::OAuth->request('Access Token')->new(%args);

	$request->sign;

	my $response = $self->get($request->to_url);

	my $content  = $response->decoded_content();
	$content = $response->content() unless defined $content;

	$self->{oauth}->{access_token}  = Net::OAuth->response('access token')->from_post_body($content);
	$self->{oauth}->{token}         = $self->{oauth}->{access_token}->token();
	$self->{oauth}->{token_secret}  = $self->{oauth}->{access_token}->token_secret();

	return;

}

sub oauth_export_config {
	my $self = shift;
	my $type = shift;

	unless ($self->is_oauth) { carp "oauth_export_config called for Non-OAuth FLickr::API object"; }

	my %oauth;

    if ($self->is_oauth && defined($type)) {
		%oauth = map { ($_) => undef }  @{Net::OAuth->request($type)->all_params()};
		foreach my $param (keys %oauth) {
			if (defined ($self->{oauth}->{$param})) { $oauth{$param} = $self->{oauth}->{$param}; }
		}
		return %oauth;
	}
	elsif ($self->is_oauth) {
		return %{$self->{oauth}};
	}
	else {
		return;
	}
}

sub is_oauth {
    my $self = shift;
    if (defined $self->{api_type} and $self->{api_type} eq 'oauth') {
        return 1;
    }
    else {
        return 0;
    }
}

#
# Private methods
#

sub _find_tag {
	my ($self, $children) = @_;
	for my $child(@{$children}){
		return $child if $child->{type} eq 'element';
	}
	return {};
}

sub _make_nonce {

    my $nonce  = String::Random->new;
    return $nonce->randpattern("cnCnCcnncnncccn");

}


1;

__END__

=head1 NAME

Flickr::API - Perl interface to the Flickr API

=head1 SYNOPSIS

=head2 Using OAuth authentication

  use Flickr::API;

  my $api = Flickr::API->new({
		'consumer_key'    => 'your_api_key',
		'consumer_secret' => 'your_app_secret',
	});

  my $response = $api->execute_method('flickr.test.echo', {
		'foo' => 'bar',
		'baz' => 'quux',
	});

=head2 Using Original Flickr authentication

  use Flickr::API;

  my $api = Flickr::API->new({
		'key'    => 'your_api_key',
		'secret' => 'your_app_secret',
	});

  my $response = $api->execute_method('flickr.test.echo', {
		'foo' => 'bar',
		'baz' => 'quux',
	});

=head2 Alternatively, Using OAuth authentication

  use Flickr::API;
  use Flickr::API::Request;

  my $api = Flickr::API->new({'consumer_key' => 'your_api_key','consumer_secret' => 'your_app_secret'});

  my $request = Flickr::API::Request->new({
		'method' => 'flickr.test.echo',
		'args' => {},
	});

  my $response = $api->execute_request($request);

=head2 Alternatively, Using Original Flickr authentication

  use Flickr::API;
  use Flickr::API::Request;

  my $api = Flickr::API->new({'key' => 'your_api_key'});

  my $request = Flickr::API::Request->new({
		'method' => 'flickr.test.echo',
		'args' => {},
	});

  my $response = $api->execute_request($request);


=head1 DESCRIPTION

A simple interface for using the Flickr API.

C<Flickr::API> is a subclass of L<LWP::UserAgent>, so all of the various
proxy, request limits, caching, etc are available. C<Flickr::API> can
instantiate using either the Flickr Authentication (deprecated) or the
OAuth Authentication.

=head1 METHODS

=over

=item C<new({ opt =E<gt> 'value', ... })>

Returns as new L<Flickr::API> object. The options are as follows:

=over

=item either C<key> for the Flickr auth or C<consumer_key> for OAuth

Your API key (one or the other form is required)

=item either C<secret> for the Flickr auth or C<consumer_secret> for OAuth

Your API key's secret (the one matching the key/consumer_key is required)

=item C<rest_uri> & C<auth_uri>

Override the URIs used for contacting the API.

=item C<lwpobj>

Base the C<Flickr::API> on this object, instead of creating a new instance of L<LWP::UserAgent>.
This is useful for using the features of e.g. L<LWP::UserAgent::Cached>.

=item C<unicode>

This flag controls whether Flickr::API expects you to pass UTF-8 bytes (unicode=0, the default) or
actual unicode strings (unicode=1) in the request.

=item C<nonce>, C<timestamp>, C<request_method>, C<signature_method>, C<request_url>

These values are used by L<Net::OAuth> to assemble and sign OAuth I<consumer> request
Flickr API calls. The defaults are usually fine.

=item C<token> and C<token_secret>

These values are used by L<Net::OAuth> to assemble and sign OAuth I<protected resource> request
Flickr API calls.


=back

=item C<execute_method($method, $args)>

Constructs a L<Flickr::API::Request> object and executes it, returning a L<Flickr::API::Response> object.

=item C<execute_request($request)>

Executes a L<Flickr::API::Request> object, returning a L<Flickr::API::Response> object. Calls are signed
if a secret was specified when creating the L<Flickr::API> object.

=item C<request_auth_url($perms,$frob)>

Returns a L<URI> object representing the URL that an application must redirect a user to for approving
an authentication token.

For web-based applications I<$frob> is an optional parameter.

Returns undef if a secret was not specified when creating the C<Flickr::API> object.

=item C<oauth_export_config()>

Returns a hash of the appropriate parameters for a particular oauth message
type if the message type is specified and is one of the message types handled
by L<Net::OAuth>. The matching key/value pairs from the L<Flickr::API> object 
are returned, otherwise the value is undef.

  my %config = $api->oauth_export_config('protected resource');

Alternatively, if called without a message type, the entire oauth
configuration from the L<Flickr::API> object is returned, including
L<Net::OAuth> I<Request Token> and I<Access Token> objects if present.

  my %config = $api->oauth_export_config();

This method can be used to extract and save the OAuth parameters for
future use.

=item C<oauth_request_token(\%args)>

Assembles, signs, and makes the OAuth B<Request Token> call, and if sucessful
stores the L<Net::OAuth> I<Request Token> in the L<Flickr::API> object.

The required paramters are:

=over

=item C<consumer_key>

Your API Key

=item C<consumer_secret>

Your API Key's secret

=item C<request_method>

The URI Method: GET or POST

=item C<request_url>

Defaults to: L<https://api.flickr.com/services/oauth/request_token>

=back

=item C<oauth_access_token(\%args)>

Assembles, signs, and makes the OAuth B<Access Token> call, and if sucessful
stores the L<Net::OAuth> I<Access Token> in the L<Flickr::API> object.

The required paramters are:

=over

=item C<consumer_key>

Your API Key

=item C<consumer_secret>

Your API Key's secret

=item C<request_method>

The URI Method: GET or POST

=item C<request_url>

Defaults to: L<https://api.flickr.com/services/oauth/access_token>

=item C<token_secret>

The request token secret from the L<Net::OAuth> I<Request Token> object
returned from the I<oauth_request_token> call.

=back

=item C<oauth_authorize_uri(\%args)>

Returns a L<URI> object representing the URL that an application must redirect a user to for approving
a request token.

=over

=item C<perms>

Permission the application is requesting, defaults to B<read>.

=back

=item C<is_oauth>

Returns B<1> if the L<Flickr::API> object is OAuth flavored, B<0> otherwise.

=back

=head1 AUTHOR

Copyright (C) 2004-2013, Cal Henderson, E<lt>cal@iamcal.comE<gt>

Auth API patches provided by Aaron Straup Cope

Subclassing patch from AHP

OAuth patches and additions provided by Louis B. Moore

=head1 SEE ALSO

L<Flickr::API::Request>,
L<Flickr::API::Response>,
L<Net::OAuth>,
L<XML::Parser::Lite>,
L<http://www.flickr.com/>,
L<http://www.flickr.com/services/api/>
L<https://www.flickr.com/services/api/auth.oauth.html>
L<https://github.com/iamcal/perl-Flickr-API>

=cut
