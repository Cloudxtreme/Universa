package Universa::Attribute::ChannelCollection;
$Universa::Attribute::ChannelCollection::VERSION = '0.001';

use Moose;
use MooseX::Params::Validate qw(pos_validated_list);
use MooseX::Types::UUID qw(UUID);

use Universa::Channel;

has '_channels'  => (
    isa          => 'HashRef[Universa::Channel|Undef]',
    traits       => ['Hash'],
    lazy         => 1,
    builder      => '_build_channels',
    handles      => {
	by_name  => 'get',
	_set     => 'set',
	_values  => 'values',
	remove   => 'delete',
	count    => 'count',
    },
    );

sub _build_channels { {} }

sub add {
    my ($self, $channel) = pos_validated_list(
	\@_,
	{ isa => 'Universa::Attribute::ChannelCollection' },
	{ isa => 'Universa::Channel' },
	);

    $self->_set($channel->name => $channel);
}

sub by_type {
    my ($self, $type) = pos_validated_list(
	{ isa => 'Universa::Attribute::ChannelCollection' },
	{ isa => 'Str' },
	);
    
    grep { $_->type eq $type } $self->_values;
}

sub by_entity {
    my ($self, $uuid) = pos_validated_list(
	\@_,
	{ isa => 'Universa::Attribute::ChannelCollection' },
	{ isa => UUID },
	);

    grep { $_->entity_by_uuid($uuid) } $self->_values;
}

__PACKAGE__->meta->make_immutable;
