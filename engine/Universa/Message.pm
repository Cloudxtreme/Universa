package Universa::Message;

use Moose;
use Moose::Util qw(apply_all_roles);
use MooseX::Types::UUID qw(UUID);
use Universa::Core qw(universa);

has 'target'    => (
    isa         => 'ArrayRef[' . UUID . '|Str]', # TODO: Coercion?
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

has 'channel'   => (
    isa         => 'Str',
    is          => 'ro',
);

has 'params'    => (
    isa         => 'HashRef[Any|Undef]',
    is          => 'ro',
    default     => sub { {} },
    );

sub send {
    my $self = shift;

    universa->demux_input($self);
}

__PACKAGE__->meta->make_immutable;
