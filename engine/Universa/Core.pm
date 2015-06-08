package Universa::Core;

use Moose;
use Moose::Util qw(apply_all_roles);
use Moose::Autobox;

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

    # consume subsystem roles:
    apply_all_roles($self, $self->config->{'subsystems'}->flatten);

	$self->universa_preinit;
    $self->universa_init;
}

__PACKAGE__->meta->make_immutable;
