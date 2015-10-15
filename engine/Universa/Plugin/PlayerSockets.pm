package Universa::Plugin::PlayerSockets;
{
    $Universa::Plugin::PlayerSockets::VERSION         = '0.1';
}

use Moose;
use IO::Socket;
use IO::Socket::INET6;
use POSIX ':sys_wait_h';

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

sub build_listen4 {
    my $self = shift;
    my $port = $self->config->{port};
    my $bind = $self->config->{ipv4_bind} || '0.0.0.0';
        
    IO::Socket::INET->new(
        Domain    => AF_INET,
        LocalAddr => $bind,
        LocalPort => $port,
        Listen    => $self->config->{'max'}  || 20,
        Reuse     => 1,
        ) or die "Can't create socket: $!\n";
}

sub build_listen6 {
    my $self = shift;
    my $port = $self->config->{port};
    my $bind = $self->config->{ipv6_bind} || '::0';
    
    IO::Socket::INET6->new(
        Domain    => AF_INET6,
        LocalAddr => $bind,
        LocalPort => $port,
        Listen    => $self->config->{'max'}  || 20,
        Reuse     => 1,
        ) or die "Can't create socket: $!\n";
}

$SIG{CHLD} = \&reaper;

sub universa_preinit {
    my $self = shift;

    $self->name('Player Sockets');
    $self->config;
}

# We start listening after all plugins have had a change to initialize:
sub universa_postinit {
    my $self = shift;

    foreach my $ipv (qw[4 6]) {
	next unless $self->config->{'ipv' . $ipv};

	my $call = 'listen' . $ipv;
	my $listener = $self->$call;
	my $bind = $self->config->{'ipv' . $ipv . '_bind'} .
	    ':' . $self->config->{'port'};

	defined(my $child_pid = fork()) or die "can't fork: $!";

	if ($child_pid) {
	    for (;;) {
		my $so_client = $listener->accept;
		$self->on_socket_accept($so_client);
	    }
	}

	print "[Player Sockets] listening for connections on $bind\n";
    }
}

sub on_socket_accept {
    my ($self, $client) = @_;

    my $player = Universa::Plugin::PlayerSockets::SocketedPlayer->new(
	_socket => $client,
	type    => 'player',
	);

    $self->core->register_entity($player);

    while (my $data = <$client>) {
	chomp $data;
	$data =~ s/^\s+|\s+$//;

	# Send an event notifying the watchers that data has arrived:
	$self->core->dispatch(
	    'EntityHandler' => 'on_entity_data' => $player, $data);
    }
    
    close $client;
}

sub reaper {
    my $child_pid;

    do {
	$child_pid = waitpid(-1, WNOHANG);
    } while $child_pid > 0;

    print "$child_pid exited\n";
}

__PACKAGE__->meta->make_immutable;

package Universa::Plugin::PlayerSockets::SocketedPlayer;
# A socketed entity type for Universa

use Moose;
use MooseX::Params::Validate;

extends 'Universa::Entity';
with 'Universa::Role::Player';

has '_socket' => (
    isa       => 'FileHandle',
    is        => 'ro',
    required  => 1,
    );


sub put {
    my ($self, $message) = pos_validated_list(
	\@_,
	{ isa => 'Universa::Plugin::PlayerSockets::SocketedPlayer' },
	{ isa => 'Universa::Message' },
	);

    # TODO: Should we perform Filtering here?
    my $socket = $self->_socket;

    use Data::Dumper;
    print $socket Dumper $message;
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
