package Universa::ChannelProxy;

use Moose::Role;
use Data::Dumper;

# If you're looking for the channel collection, see Universa::DEMUX.

sub channel {
    my ($self, $name) = @_;

    # Return the channel by name if provided:
    return $self->demux_channel_by_name($name) if $name;

    # Otherwise, we are talking to the channel manager:
    Universa::ChannelManagement->new;
}

# Create the Universa channel for tunneling dispatch events:
after 'universa_init' => sub { shift->channel->create(name => 'universa') };

after 'dispatch' => sub {
    my $channel = shift->channel('universa');
    print Dumper $channel;

    #$channel->message(
    #    target => [ ':in' ],
    #    name   => 'core_dispatch',
    #    params => \@_[1 .. $#_],
    #)->send;
}; 

1;

package Universa::ChannelManagement;

use Moose;
use Universa::Core qw(universa);
use Universa::Entity;

sub create { Universa::Channel->new(@_[1 .. $#_])->register }

__PACKAGE__->meta->make_immutable;
