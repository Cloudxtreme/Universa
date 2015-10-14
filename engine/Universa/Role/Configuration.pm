package Universa::Role::Configuration;
#  Integrate SimpleConfig in a Universa::PluginSystem friendly manner

use MooseX::Role::Parameterized;
use FindBin qw($Bin);

parameter 'configfile' => ( isa => 'Str', required => 1               );
parameter 'class'      => ( isa => 'Str', required => 1               );
parameter 'store'      => ( isa => 'Str', default  => 'config'        );
parameter 'builder'    => ( isa => 'Str', default  => '_build_config' );
parameter 'confdir'    => ( isa => 'Str', default  => "$Bin/etc"      );

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
	
	print "TEST: " . $params->configfile . "\n";

	# Create the file if it doesn't exist or is empty:
	if (! -f $params->confdir . '/' . $params->configfile) {
	    
	    open my $fh, '>',
	    $params->confdir . '/' . $params->configfile or die $!;
	    
	    {
		local $/ = undef;
		my $data = $params->class . '::DATA';
		my $config = <$data>;
		print $fh $config;
	    }
	}

	$params->class->new_with_config(
	    configfile => $params->confdir . '/' . $params->configfile );
    }
};
