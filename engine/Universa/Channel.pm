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

sub _build_entities {
    Universa::Attribute::EntityCollection->new;
}
    
__PACKAGE__->meta->make_immutable;
