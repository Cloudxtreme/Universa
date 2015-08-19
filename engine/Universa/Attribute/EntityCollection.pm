package Universa::Attribute::EntityCollection;
$Universa::Attribute::EntityCollection::VERSION = '0.001';

use Moose;
use MooseX::Params::Validate qw(pos_validated_list);
use Universa::Entity;

has '_entities'  => (
    isa          => 'ArrayRef[Universa::Entity|Undef]',
    traits       => ['Array'],
    is           => 'rw',
    lazy         => 1,
    builder      => '_build_entities',
    handles      => {
	add      => 'push',
	count    => 'count',
    },
    );

sub build_entities { [] }

sub by_uuid {
    my ($self, $uuid) = pos_validated_list(
	\@_,
	{ isa => 'Universa::Attribute::EntityCollection' },
	{ isa => 'Str' },
	);

    $self->_entities->first( sub { $_->uuid eq $uuid } );
}

sub by_name {
    my ($self, $name) = pos_validate_list(
	\@_,
	{ isa => 'Universa::Attribute::EntityCollection' },
	{ isa => 'Str' },
	);

    $self->_entities->first( sub { $_->name eq $name } );
}

sub remove {
    my ($self, $uuid) = pos_validated_list(
	\@_,
	{ isa => 'Universa::Attribute::EntityCollection' },
	{ isa => 'Str' },
	);

    $self->_entities( $self->_entities->grep( sub { $_->uuid ne $uuid } ) );
}

__PACKAGE__->meta->make_immutable;
