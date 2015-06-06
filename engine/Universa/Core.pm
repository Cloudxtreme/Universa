package Universa::Core;

use Moose;
use Universa::Config;

with 'Universa::Role::Configuration' => {
    configfile => 'universa.yml',
    class      => 'Universa::Config',
};


# Apply method modifiers to these in your subsystems:
sub universa_preinit {}
sub universa_init    {}

sub start {
    my $self = shift;

    $self->universa_preinit;
    $self->universa_init;
}

# Subsystems:
with 'Universa::PluginSystem'; # Provides a simple yet powerful plugin system
with 'Universa::DEMUX';        # Demultiplexes game library output

__PACKAGE__->meta->make_immutable;
