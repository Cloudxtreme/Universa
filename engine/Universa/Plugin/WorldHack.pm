package Universa::Plugin::WorldHack;

use Moose;
use Moose::Util qw(apply_all_roles);

use lib qw(lib); # TODO: fix this
use controller::auth;

with 'Universa::Role::Plugin';
with 'Universa::Role::EntityHandler';


sub register_entity {
    my ($self, $entity) = @_;
    return unless $entity->type eq 'player';

    # All players have inventories:
    my $auth = $self->core->demux_create_channel(
	type => '__login__',
	name => $entity->id . '.inv',
	);

    $auth->add_entity($entity);

    # The inventory channel does not hold only inventory items,
    # It is a channel that holds all of the roles and assets of
    # a player.

    $auth->info->{'controller'} = controller::auth->new(
	core    => $self->core,
	channel => $inventory,
	);
}

sub on_entity_data {
    my ($self, $entity, $data) = @_;
    
    foreach my $channel ( $self->core->demux_channels_by_entity($entity->id) ) {
	my $controller = $channel->info->{'controller'};
	$controller->raw_input($entity, $data)
	    if $controller->can('raw_input');
    }
}

__PACKAGE__->meta->make_immutable;
