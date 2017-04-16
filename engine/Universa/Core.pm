package Universa::Core;

use Moose;
use Moose::Util qw(apply_all_roles);
use Moose::Autobox;
use Moose::Exporter;
use IO::Async::Loop;

use Universa::Config;

with 'Universa::Role::Configuration' => {
    configfile => 'universa.yml',
    class      => 'Universa::Config',
};

our $UNIVERSA; # Singleton reference

Moose::Exporter->setup_import_methods(
    'as_is' => [ 'universa' => \&universa ],
    );

# Apply method modifiers to these in your subsystems:
sub universa_preinit  {}
sub universa_postinit {}
sub universa_init     {}
sub dispatch          {} # ($role, $call, @args)

# Fancy syntax sugar + exporty things:
sub universa { $Universa::Core::UNIVERSA }
sub BUILD    { $Universa::Core::UNIVERSA ||= shift }

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

    IO::Async::Loop->new->run;
}

__PACKAGE__->meta->make_immutable;
