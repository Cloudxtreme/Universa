package Universa::Channel;

use Moose;
use Universa::Attribute::EntityCollection;
use Universa::Core qw(universa);

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
    my ($self, $message) = @_;
    
    if ($message->target->[0] eq ':all') {
	# Broadcast message:

	    foreach my $entity ( $self->_entities->_values ) {
	        $entity->put($message);
	    }
    }

    # Used for game input. i.e. client socket -> watcher
    elsif ($message->target->[0] eq ':in') {
        universa->dispatch( 'ChannelWatcher' => 'on_channel_input' => $message )
    }

    else {
	    foreach my $uuid ( @{ $message->target } ) {

	        if (my $entity = universa->entity($uuid)) {
		        $entity->put($message);
	        }
	    }
    }
}

sub message {
    my ($self, %params) = @_;

    Universa::Message->new(
        channel => $self->name,
        %params,
    );
}

sub register {
    my $self = shift;

    universa->demux_register_channel($self);
    $self;
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
