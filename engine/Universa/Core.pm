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
sub universa_preinit  {}
sub universa_postinit {}
sub universa_init     {}

sub start {
    my $self = shift;

    # TODO: Let the initialization script handle this?:
    mkdir 'etc' unless -d 'etc';
    
    print "the following subsystems will be loaded:\n"
	. join("\n", $self->config->{'subsystems'}->flatten);
    print chr(10)x2;

    # consume subsystem roles:
    apply_all_roles($self, $self->config->{'subsystems'}->flatten);

    my @init_levels = qw(
        universa_preinit
        universa_init
        universa_postinit
    );

    $self->$_() foreach (@init_levels);
    print "ready.\n";
    sleep;
}

__PACKAGE__->meta->make_immutable;
