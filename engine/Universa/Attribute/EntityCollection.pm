package Universa::Attribute::EntityCollection;
$Universa::Attribute::EntityCollection::VERSION = '0.001';

use Moose;

with 'MooseX::Params::Validate';
with 'MooseX::OneArgNew' => {
    type     => 'ArrayRef[Universa::Role::Entity|ArrayRef[Undef]',
    init_arg => '_entities',
};

has '_entities'  => (
    does         => 'ArrayRef[Universa::Role::Entity|ArrayRef[Undef]',
    traits       => ['Array'],
    is           => 'ro',
    lazy         => 1
    builder      => '_build_entities',
    handles      => {
	add      => 'push',
	count    => 'count',
	is_empty => 'is_empty',
    );

sub build_entities { [] }

sub by_uuid {
    my ($self, $uuid) = pos_validated_list(
	\@_,
	{ isa => 'Universa::Attribute::EntityCollection' },
	{ isa => 'Str' },
	);

    first { $_->uuid eq $uuid } @{ $self->_entities };
}

sub by_name {
    my ($self, $name) = pos_validate_list(
	\@_,
	{ isa => 'Universa::Attribute::EntityCollection' },
	{ isa => 'Str' },
	);

    first { $_->name eq $name } @{ $self->_entities };
}

sub remove {
    my ($self, $uuid) = pos_validated_list(
	\@_,
	{ isa => 'Universa::Attribute::EntityCollection' },
	{ isa => 'Str' },
	);

    # TODO: Remove an entity by UUID
}

__PACKAGE__->meta->make_immutable;
