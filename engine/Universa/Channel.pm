package Universa::Channel;

use Moose;

has '_entities' => (
    does        => 'ArrayRef[Universa::Role::Entity',
    is          => 'ro',
    builder     => 'build_entities',
    lazy        => 1,
    );

has 'name'      => (
    isa         => 'Str',
    is          => 'ro',
    default     => '',
    lazy        => 1,
    );

# For indexing purposes:
has 'type'      => (
    isa         => 'Str',
    is          => 'ro',
    default     => '',
    lazy        => 1,
    );


    
__PACKAGE__->meta->make_immutable;
