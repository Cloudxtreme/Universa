package Universa::DEMUX;
# The Universa demultiplexer subsystem

use Moose::Role;
use MooseX::Params::Validate qw(pos_validated_list);
use Universa qw(Attribute::ChannelCollection Channel);

has '_demux_channels'            => (
    isa                          => 'Universa::Attribute::ChannelCollection',
    is                           => 'ro',
    lazy                         => 1,
    builder                      => '_build_channels',
    handles                      => {
	demux_register_channel       => 'add',
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
	{ isa  => 'Universa::Message' },
	);

    if ( $message->channel ) {
        $self->demux_channel_by_name($message->channel)->put($message);
    }
}

1;
