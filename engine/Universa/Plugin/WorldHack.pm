package Universa::Plugin::WorldHack;

use Moose;
use lib qw(lib);

use controller::master;

with 'Universa::Role::Plugin';
with 'Universa::Role::ChannelWatcher';

sub on_channel_input {
    my ($self, $message) = @_;

    controller::master->in($message);
}

__PACKAGE__->meta->make_immutable;
