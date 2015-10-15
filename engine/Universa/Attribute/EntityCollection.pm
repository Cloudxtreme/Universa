package Universa::Attribute::EntityCollection;
$Universa::Attribute::EntityCollection::VERSION = '0.001';

use Moose;
use MooseX::Params::Validate qw(pos_validated_list);
use Universa::Entity;

has '_entities'  => (
    isa          => 'HashRef[Universa::Entity|Undef]',
    traits       => ['Hash'],
    lazy         => 1,
    builder      => '_build_entities',
    handles      => {
	by_uuid  => 'get',
	_set     => 'set',
	remove   => 'delete',
	count    => 'count',
    },
    );

sub _build_entities { {} }

sub add {
    my ($self, $entity) = pos_validated_list(
	\@_,
	{ isa => 'Universa::Attribute::EntityCollection' },
	{ isa => 'Universa::Entity' },
	);

    $self->_set($entity->id => $entity);
}

__PACKAGE__->meta->make_immutable;
