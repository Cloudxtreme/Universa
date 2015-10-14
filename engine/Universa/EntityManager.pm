package Universa::EntityManager;

use Moose::Role;
use MooseX::Params::Validate;
use Moose::Autobox;

use Universa qw(Attribute::EntityCollection Entity);

has '_entities' => (
    isa         => 'Universa::Attribute::EntityCollection',
    is          => 'ro',
    builder     => '_build_entities',
    lazy        => 1,
    );


sub register_entity {
    my ($self, $entity) = pos_validated_list(
	\@_,
	{ does => __PACKAGE__ },
	{ isa  => 'Universa::Entity' },
	);

    $self->_entities->add($entity);
    $self->dispatch('EntityHandler' => 'register_entity' => $entity);
}

sub _build_entities { Universa::Attribute::EntityCollection->new }

1;
