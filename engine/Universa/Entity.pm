package Universa::Entity;

use Moose;
use Data::GUID;

has 'id'        => (
    isa         => 'Str',
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


sub build_id { Data::GUID->new->as_string }

# Template for Entity meta information
sub build_info {
    {
	'name' => '',
    }
}

# Data input:
sub put {}

1;
