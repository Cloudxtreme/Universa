package Universa::Message;

use Moose;
use Moose::Util qw(apply_all_roles);
use MooseX::Types::UUID qw(UUID);

has 'target'    => (
    isa         => 'ArrayRef[' . UUID . ']|Str', # TODO: Coercion?
    is          => 'ro',
    required    => 1,
    );

has 'source'    => (
    isa         => UUID,
    is          => 'ro',
    );

has 'observers' => (
    isa         => 'ArrayRef[' . UUID . ']|Str',
    is          => 'ro',
    );

has 'type'      => (
    isa         => 'Str',
    is          => 'ro',
    required    => 1,
    );

has 'params'    => (
    isa         => 'HashRef[Any|Undef]',
    is          => 'ro',
    default     => sub { {} },
    );

__PACKAGE__->meta->make_immutable;
