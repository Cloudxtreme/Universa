package Universa::Plugin::PlayerSockets;
{
    $Universa::Plugin::PlayerSockets::VERSION         = '0.1';
}

use Moose;
use IO::Socket;

with 'Universa::Role::Plugin';
with 'Universa::Role::Initialization';

with 'Universa::Role::Configuration' => {
    class      => 'Universa::Plugin::PlayerSockets::Config',
    configfile => 'playersockets.yml', 
};

has 'listen4' => (
    isa       => 'FileHandle',
    is        => 'rw',
    builder   => 'build_listen4',
    lazy      => 1,
    );

has 'listen6' => (
    isa       => 'FileHandle',
    is        => 'rw',
    builder   => 'build_listen6',
    lazy      => 1,
    );


sub universa_preinit {
    my $self = shift;

    $self->name('Player Sockets');
    $self->config;
}

sub build_listen4 {
    my $self = shift;
    my $port = $self->config->{port};
    my $bind = $self->config->{ipv4_bind} || '0.0.0.0';
    
    my $socket = IO::Socket::INET->new(
        Domain    => AF_INET,
        LocalAddr => $bind,
        LocalPort => $port,
        Listen    => $self->config->{'max'}  || 20,
        Blocking  => 0,
        Reuse     => 1,
        ) or die "Can't create socket: $!\n";
    print "listening for connections on $bind:$port\n";
    
    $socket;
}

sub build_listen6 {
    my $self = shift;
    my $port = $self->config->{port};
    my $bind = $self->config->{ipv6_bind} || '::0';
    
    my $socket = IO::Socket::INET6->new(
        Domain    => AF_INET6,
        LocalAddr => $bind,
        LocalPort => $port,
        Listen    => $self->config->{'max'}  || 20,
        Blocking  => 0,
        Reuse     => 1,
        ) or die "Can't create socket: $!\n";
    print "listening for connections on $bind:$port\n";

    $socket;
}

__PACKAGE__->meta->make_immutable;

package Universa::Plugin::PlayerSockets::SocketedPlayer;
# A socketed entity type for Universa

use Moose;

with 'Universa::Role::PlayerEntity';

has '_socket' => (
    isa       => 'FileHandle',
    is        => 'ro',
    required  => 1,
    );


sub put {
    my ($self, $data) = pos_validated_list(
	\@_,
	{ isa => 'Universa::Plugin::PlayerSockets::SocketedEntity' },
	{ isa => 'Any' }, # TODO: use a worthy type constraint (not string? )
	);

    # TODO: Should we perform Filtering here?
    my $socket = $self->_socket;
    print $socket $data;
}

__PACKAGE__->meta->make_immutable;

package Universa::Plugin::PlayerSockets::Config;

use Moose;
with 'MooseX::SimpleConfig';


has 'port' => ( isa => 'Int',  is => 'ro', default => 9001 );
has 'ipv4' => ( isa => 'Bool', is => 'ro', default => 1    );
has 'ipv6' => ( isa => 'Bool', is => 'ro',default => 0     );
has 'ipv4_bind' => ( isa => 'Str', is  => 'ro', default => '127.0.0.1' );
has 'ipv6_bind' => ( isa => 'Str', is  => 'ro', default => '::1'       );
has 'read_file' => ( isa => 'Bool', is => 'ro', default => 0           );

__PACKAGE__->meta->make_immutable;

__DATA__
---
# Configuration template for Universa::Plugin::PlayerSockets:
# Default values are commented out when this file is created.

#  port: 9001

#  Set any of these to a false value and they will be disabled. True otherwise:
#  ipv4: 1
#  ipv6: 0

# The following settings default to localhost. Be sure to change these
# if you are planning to run Universa on a network. To listen on all interfaces,
# 0.0.0.0 and ::0 might be sane choices:
#  ipv4_bind: 127.0.0.1
#  ipv6_bind: ::1
read_file: 0 # Set this to 1 if you have read this file
...
