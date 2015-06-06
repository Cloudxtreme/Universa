package Universa::DEMUX;
# The Universa demultiplexer subsystem

use Moose::Role;
use Moose::Autobox;

use List::Util qw(first);

has '_channels' => (
    isa         => 'Universa::Channel',
    is          => 'ro',
    builder     => 'build_channels',
    lazy        => 1,
    );


sub channel_by_name {
    my ($self, $name) = pos_validated_list(
	\@_,
	{ isa => 'Universa::DEMUX' },
	{ isa => 'Str' },
	);

    first { $_->name eq $name } $self->_channels->flatten;
}

sub channels_by_type {
    my ($self, $type) = pos_validated_list(
	\@_,
	{ isa => 'Universa::DEMUX' },
	{ isa => 'Str' },
	);

    grep { $_->type eq $type } $self->_channels->flatten;
}

sub channels_by_entity {
    my ($self, $id) = pos_validated_list(
	\@_,
	{ isa => 'Universa::DEMUX' },
	{ isa => 'Str' },
	);

    grep { $_->entity_by_id($id) } $self->_channels->flatten;
}

sub build_channels {
    # TODO
}

1;
