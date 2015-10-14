package Universa::Channel;

use Moose;
use Universa::Attribute::EntityCollection;

has '_entities' => (
    isa         => 'Universa::Attribute::EntityCollection',
    is          => 'ro',
    builder     => '_build_entities',
    lazy        => 1,
    handles     => {
	add_entity => 'add',
	count_entities => 'count',
	entity_by_uuid => 'by_uuid',
	entity_by_name => 'by_name',
	remove_entity  => 'remove',
    },
    );

has 'name'      => (
    isa         => 'Str',
    is          => 'ro',
    default     => '',
    lazy        => 1,
    );

# For indexing purposes:
has 'type'      => (
    isa         => 'Str',
    is          => 'ro',
    default     => '',
    lazy        => 1,
    );

has 'info'      => (
    isa         => 'HashRef[Any]',
    is          => 'ro',
    builder     => '_build_info',
    lazy        => 1,
    );


sub put {
    my ($self, $args) = @_;

    if ($args->{'target'} eq ':all') {
	# Broadcast message:
	foreach my $entity ( $self->_entities->values ) {
	    $entity->put($args);
	}
    }

    else {
	foreach my $uuid ( @{ $args->{'target'} } ) {
	    if (my $entity = $self->entity_by_uuid($uuid)) {
		$entity->put($args);
	    }
	}
    }
}

sub _build_info { {} }

sub _build_stub { Universa::Channel::Stub->new }

sub _build_entities {
    Universa::Attribute::EntityCollection->new;
}
    
__PACKAGE__->meta->make_immutable;

package Universa::Channel::Stub;

use Moose;


# Stub

__PACKAGE__->meta->make_immutable;
