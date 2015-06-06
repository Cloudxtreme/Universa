package Universa::PluginSystem;

use Moose::Role;
use Moose::Autobox;

use Module::Runtime qw(require_module);


sub _build_plugins {
    my $self = shift;
    my @autoloaded = ();
    
    if (exists ($self->config->{'plugins'})) {
	my $plugins = $self->config->{'plugins'};
	
        foreach my $plugin ($self->config->{'plugins'}->flatten) {
	    
            print "Loading plugin: '$plugin'\n";
            my $plugin = $self->_load_plugin($plugin);
	    push @autoloaded, $plugin;
        }
    }

    \@autoloaded;
}

# All of the heavy lifting is done for us by the following role:
with 'Universa::Role::PluginManagement' => {
    autoloader          => '_build_plugins',
    role_restriction    => 'Universa::Role::Plugin',
    with_prefix         => 'Universa::Role',
};

# override for load_plugin to pass core instance to constructor:
# TODO: Fix PluginManagement so that it will accept arguments to plugins
sub _load_plugin {
    my ($self, $plugin_name) = @_;
    # We ignore orig here, because we are replacing it.
    
    require_module($plugin_name);
    my $plugin_obj = $plugin_name->new( core => $self );
    $plugin_obj;
}

# Load autoloadable plugins and pre_init() them:
after 'universa_preinit' => sub {
    my $self = shift;
    
    $self->_plugins;
    $self->dispatch('Initialization' => 'universa_preinit');
};

after 'universa_init' => sub {
    shift->dispatch('Initialization' => 'universa_init');
};
    
1;
