package Universa::EntityProxy;

use Moose::Role;
use MooseX::Params::Validate;
use Moose::Autobox;

use Universa qw(Attribute::EntityCollection Entity);

has '_entities' => (
    isa         => 'Universa::Attribute::EntityCollection',
    is          => 'ro',
    builder     => '_build_entities',
    lazy        => 1,
    handles     => {
        add_entity => 'add', # Helper
    },
    );

sub entity {
    my ($self, $uuid) = @_;

    # Return entity object if uuid is specified:
    return $self->_entities->by_uuid($uuid) if $uuid;

    # Otherwise, we are talking to the entity manager:
    Universa::EntityManagement->new;
}

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

package Universa::EntityManagement;

use Moose;
use Universa::Core qw(universa);
use Universa::Entity;


sub create { Universa::Entity->new(@_[1 .. $#_])->register }

__PACKAGE__->meta->make_immutable;
