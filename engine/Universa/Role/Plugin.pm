package Universa::Role::Plugin;

use Moose::Role;


has 'name' => (
    isa    => 'Str',
    is     => 'rw',
    );

has 'core'   => (
    isa      => 'Universa::Core',
    is       => 'ro',
    required => 1,
    );

sub dprint {
    my ($self, @args) = @_;
}

1;
