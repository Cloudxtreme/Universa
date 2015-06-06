package Universa::Role::Entity;

use Moose::Role;
use Data::GUID;

has 'id'        => (
    isa         => 'Str',
    is          => 'ro',
    builder     => 'build_id',
    lazy        => 1,
    );

has 'info'      => (
    isa         => 'HashRef[Any]',
    is          => 'ro',
    builder     => 'build_info',
    lazy        => 1,
    );


sub build_id {
    my $self = shift;

    # TODO
}

# Template for Entity meta information
sub build_info {
    {
	'name' => '',
    }
}

requires 'put';

1;
