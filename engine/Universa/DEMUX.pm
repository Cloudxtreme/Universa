package Universa::DEMUX;
# The Universa demultiplexer subsystem

use Moose::Role;
use MooseX::Params::Validate qw(pos_validated_list);
use Universa qw(Attribute::ChannelCollection Channel);

has '_demux_channels'            => (
    isa                         => 'Universa::Attribute::ChannelCollection',
    is                           => 'ro',
    lazy                         => 1,
    builder                      => '_build_channels',
    handles                      => {
	demux_add_channel        => 'add',
	demux_remove_channel     => 'remove',
	demux_channel_by_name    => 'by_name',
	demux_channels_by_type   => 'by_type',
	demux_channels_by_entity => 'by_entity',
    },
    );

sub _build_channels { Universa::Attribute::ChannelCollection->new }

sub demux_input {
    my ($self, $message) = pos_validated_list(
	\@_,
	{ does => 'Universa::DEMUX' },
	{ isa  => 'Universa::DEMUX::Message' },
	);

    my $next_target = $self->_demux_get_targets($message);
    while (my ($entity, $type) = $next_target->() ) {
	$entity->put($type, $message);
    }
}

sub demux_create_channel {
    my ($self, @params) = @_;

    if ( defined(my $channel = Universa::Channel->new(@params)) ) {
	$self->demux_add_channel($channel);
	return $channel;
    }
}

sub _demux_get_targets {
    my ($self, $message) = pos_validated_list(
	\@_,
	{ does => 'Universa::DEMUX' },
	{ isa  => 'Universa::DEMUX::Message' },
	);

    my $channel = $self->demux_channel_by_name($message->channel);
    # TODO
}

1;
