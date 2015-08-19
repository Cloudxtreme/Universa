package Universa::Attribute::ChannelCollection;
$Universa::Attribute::ChannelCollection::VERSION = '0.001';

use Moose;
use MooseX::Params::Validate qw(pos_validated_list);
use Universa::Channel;

has '_channels'  => (
    isa          => 'ArrayRef[Universa::Channel|Undef]',
    traits       => ['Array'],
    is           => 'rw',
    lazy         => 1,
    builder      => '_build_channels',
    handles      => {
	add      => 'push',
	count    => 'count',
	is_empty => 'is_empty',
    },
    );

sub _build_channels { [] }

sub by_name {
    my ($self, $name) = pos_validated_list(
	\@_,
	{ isa => 'Universa::Attribute::ChannelCollection' },
	{ isa => 'Str' },
	);

    $self->_channels->first( sub { $_->name eq $name } );
}

sub by_type {
    my ($self, $type) = pos_validated_list(
	{ isa => 'Universa::Attribute::ChannelCollection' },
	{ isa => 'Str' },
	);

    $self->_channels->grep( sub { $_->type eq $type } );
}

sub by_entity {
    my ($self, $uuid) = pos_validate_list(
	\@_,
	{ isa => 'Universa::Attribute::ChannelCollection' },
	{ isa => 'Str' },
	);

    $self->_channels->grep( sub { $_->entity_by_uuid($uuid) } );
}

sub remove {
    my ($self, $name) = pos_validated_list(
	\@_,
	{ isa => 'Universa::Attribute::ChannelCollection' },
	{ isa => 'Str' },
	);

    $self->_channels( $self->_channels->grep( sub { $_->name ne $name } ) );

}

__PACKAGE__->meta->make_immutable;
