package Universa::Plugin::PlayerSockets;
{
    $Universa::Plugin::PlayerSockets::VERSION         = '0.1';
}

use Moose;
use IO::Socket;
use IO::Socket::INET6;
use IO::Async::Listener;
use IO::Async::Loop;

use Universa::Core qw(universa);
use Universa::Message;

with 'Universa::Role::Plugin';
with 'Universa::Role::Initialization';

with 'Universa::Role::Configuration' => {
    class      => 'Universa::Plugin::PlayerSockets::Config',
    configfile => 'playersockets.yml', 
};

sub universa_preinit {
    my $self = shift;

    $self->name('Player Sockets');
    $self->config;
}

# We start listening after all plugins have had a change to initialize:
sub universa_postinit {
    my $self = shift;

    my $loop = IO::Async::Loop->new;
    my $listener = IO::Async::Listener->new(
        on_stream => sub {
            my (undef, $stream) = @_;

            # Client connected:
            my $player = universa->entity->create( type => 'player' );
            my $filter = Universa::Plugin::PlayerSockets::SocketFilter->new(
	        _stream => $stream,
	        stage   => 'Port',
	        );

            $player->add_filter($filter);
            my $inventory = universa->channel->create( name => 'inv:' . $player->id );
            $player->info->{'inv_channel'} = $inventory; # Entities almost talk to themselves.

            $stream->configure(
                on_read => sub {
                    my ($self, $bufref, $eof) = @_;

                    $player->info->{'inv_channel'}->message(
                        target   => [ ':in' ],
                        type     => 'player_socket_input', 
                        params   => {
                            data => $$bufref,
                        },
                    )->send;

                    $$bufref = "";
                    return 0;
                },
            );

            $loop->add($stream);
        }
    );

    $loop->add($listener);
    $listener->listen(
        addr => {
            socktype => 'stream',
            family   => 'inet',
            port     => $self->config->{'port'},
            ip       => $self->config->{'ipv4_bind'},
        },
    )->get;
}

__PACKAGE__->meta->make_immutable;

package Universa::Plugin::PlayerSockets::SocketedPlayer;
# A socketed entity type for Universa

use Moose;
use MooseX::Params::Validate;

extends 'Universa::Entity';
with 'Universa::Role::Player';

__PACKAGE__->meta->make_immutable;

package Universa::Plugin::PlayerSockets::SocketFilter;
# Terminating filter for ScoketedEntity
# Terminating filters are the only filters in Universa
# that should be holding any form of state.

use Moose;
extends 'Universa::Filter';

has '_stream' => (
    isa       => 'IO::Async::Stream',
    is        => 'ro',
    required  => 1,
    );


sub put {
    my ($self, $data) = @_;

    my $socket = $self->_stream;

    use Data::Dumper;
    $socket->write( $data );
}

__PACKAGE__->meta->make_immutable;

package Universa::Plugin::PlayerSockets::Config;

use Moose;
with 'MooseX::SimpleConfig';

has 'port' => ( isa => 'Int',  is => 'ro', default => 9001 );
has 'ipv4' => ( isa => 'Bool', is => 'ro', default => 0    );
has 'ipv6' => ( isa => 'Bool', is => 'ro',default => 0     );
has 'ipv4_bind' => ( isa => 'Str', is  => 'ro', default => '127.0.0.1' );
has 'ipv6_bind' => ( isa => 'Str', is  => 'ro', default => '::1'       );
has 'read_file' => ( isa => 'Bool', is => 'ro', default => 0           );

__PACKAGE__->meta->make_immutable;

__DATA__
---
# Configuration template for Universa::Plugin::PlayerSockets:
# Default values are commented out when this file is created.

# port: 9001

#  Set any of these to a false value and they will be disabled. True otherwise:
ipv4: 1
# ipv6: 0

# The following settings default to localhost. Be sure to change these
# if you are planning to run Universa on a network. To listen on all interfaces,
# 0.0.0.0 and ::0 might be sane choices:
# ipv4_bind: 127.0.0.1
# ipv6_bind: ::1
...
