package Universa::Plugin::Example;

use Moose;
with 'Universa::Role::Plugin';
with 'Universa::Role::Initialization';


# Basic setup of the plugin, setting its name, etc:
sub universa_preinit {
    my $self = shift;

    $self->name('Example plugin');
}

# Post engine initialization hook:
sub universa_postinit {
    print "[Example Plugin]: All plugins should have loaded by now.\n";
}

__PACKAGE__->meta->make_immutable;
