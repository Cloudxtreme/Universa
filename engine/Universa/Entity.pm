package Universa::Entity;

use Moose;
use MooseX::Types::UUID qw(UUID);
use Data::UUID;

has 'id'        => (
    isa         => UUID,
    is          => 'ro',
    builder     => 'build_id',
    lazy        => 1,
    );

has 'info'      => (
    isa         => 'HashRef[Any]',
    is          => 'ro',
    builder     => 'build_info',
    lazy        => 1,
    );

has 'type'      => (
    isa         => 'Str',
    is          => 'ro',
    required    => 1,
    );


sub build_id {
    my $ug = Data::UUID->new;
    $ug->to_string($ug->create);
 }

# Template for Entity meta information
sub build_info {
    {
	'name' => '',
    }
}

sub BUILD {} # Stub

with 'Universa::Role::FilterPipeline' => {
    stages => ['Gate' => 'Port'],
};

1;
