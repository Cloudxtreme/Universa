package Universa::Role::Configuration;
#  Integrate SimpleConfig in a Universa::PluginSystem friendly manner

use MooseX::Role::Parameterized;

parameter 'configfile' => ( isa => 'Str', required => 1               );
parameter 'class'      => ( isa => 'Str', required => 1               );
parameter 'store'      => ( isa => 'Str', default  => 'config'        );
parameter 'builder'    => ( isa => 'Str', default  => '_build_config' );

role {
    my $params = shift;

    has $params->store  => (
	does     => 'MooseX::SimpleConfig',
	is       => 'ro',
	builder  => '_build_config',
	lazy     => 1,
	);

    method $params->builder => sub {
	my $self = shift;
	
	# Create the file if it doesn't exist or is empty:
	if (! -f 'etc/' . $params->configfile) {
	    
	    open my $fh, '>', 'etc/' . $params->configfile or die $!;
	    {
		local $/ = undef;
		my $data = $params->class . '::DATA';
		my $config = <$data>;
		print $fh $config;
	    }
	}

	$params->class->new_with_config(
	    configfile => 'etc/' . $params->configfile
	    );
    }
};
