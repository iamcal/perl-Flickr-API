package Flickr::Types;
use Carp;
use Type::Library
   -base,
   -declare => qw( Personsearch Personuser );
use Type::Utils -all;
use Types::Standard -types;


declare Personsearch,
   as Dict[
      email     => Optional[Str],
      username  => Optional[Str],
   ];

declare Personuser,
    as HashRef;



1;
