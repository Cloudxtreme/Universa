package Universa::Config;

use Moose;

with 'MooseX::SimpleConfig';


has 'plugins' => (
    isa => 'ArrayRef[Str]',
    is  => 'ro',
    );

__PACKAGE__->meta->make_immutable;
