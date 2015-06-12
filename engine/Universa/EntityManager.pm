package Universa::EntityManager;

use Moose::Role;
use MooseX::Params::Validate;
use Moose::Autobox;

use Universa::Entity;

has '_entities' => (
    isa     => 'ArrayRef[Universa::Entity]',
    is      => 'ro',
    builder => '_build_entities',
    lazy    => 1,
    );


sub register_entity {
    my ($self, $entity) = pos_validated_list(
	\@_,
	{ does => __PACKAGE__ },
	{ isa  => 'Universa::Entity' },
	);

    $self->_entities->push($entity);
    print "registered entity '@{ [ $entity->id ] }'\n";
}

sub _build_entities {
    my $self = shift;
    
    # TODO: Load superstatic entities
    [ Universa::Entity->new( id => 'DUMMY') ];
}

1;
