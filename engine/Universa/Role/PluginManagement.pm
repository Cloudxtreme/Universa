package Universa::Role::PluginManagement;

use Moose::Role;
use Moose::Autobox;
use MooseX::Role::Parameterized;
use MooseX::Params::Validate qw(pos_validated_list);

use List::Util qw(first);
use Module::Runtime qw(require_module);


parameter 'autoloader'  => ( isa => 'Str',                        );
parameter 'store'       => ( isa => 'Str', default  => '_plugins' );
parameter 'with_prefix' => ( isa => 'Str', default  => ''         );


role {
    my $params = shift;
    my $store  = $params->store;

    
    has $params->store => (
	isa            => 'ArrayRef[Any]',
	is             => 'rw',
	#traits         => [ 'Array' ],
	builder        => $params->autoloader || undef,
	lazy           => 1,
	);
    
    # Please ignore. You want to use load_plugin instead.
    # Returns a plugin object:
    method '_load_plugin' => sub {
	my ($self, $plugin_name) = @_;
	
	require_module($plugin_name);
        my $plugin_obj = $plugin_name->new;
        $plugin_obj;
    };
    
    # Loads a plugin, storing it into $params->store:
    method 'load_plugin' => sub {
	my ($self, $plugin_name) = pos_validated_list(
	    \@_,
	    { does => __PACKAGE__ },
	    { isa  => 'Str' },
	    );
	
        my $plugin = $self->_load_plugin($plugin_name);
        
        $self->$store->push($plugin);
        $plugin;
    };
    
    method 'plugins_with' => sub {
	my ($self, $role) = pos_validated_list(
	    \@_,
	    { does => __PACKAGE__ },
	    { isa  => 'Str' },
	    );
	
        my $prefix = $params->with_prefix; 
        $prefix .= '::' if $prefix;
	grep { $_->does($prefix . $role) } $self->$store->flatten;
    };
    
    method 'plugin_named' => sub {
	my ($self, $name) = pos_validated_list(
	    \@_,
	    { does => __PACKAGE__ },
	    { isa  => 'Str' },
	    );

	first { $_->name eq $name } $self->$store->flatten;
    };

    after 'dispatch' => sub {
	my ($self, $role, $call, @args) = pos_validated_list(
	    \@_,
	    { does => __PACKAGE__ },
	    { isa  => 'Str' },
	    { isa  => 'Str' },
	    MX_PARAMS_VALIDATE_ALLOW_EXTRA => 1,
	    );

	foreach my $plugin ($self->plugins_with($role)) {
	    $plugin->$call(@args) if $plugin->can($call);
	}
    };
};
