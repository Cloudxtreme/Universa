package Universa::Attribute::FilterCollection;

use Moose;


has '_filters'  => (
    isa         => 'ArrayRef[Universa::Filter|Undef]',
    traits      => ['Array'],
    lazy        => 1,
    builder     => '_build_filters',
    handles     => {
	add     => 'push',
	filters => 'elements',
    },
    );


sub _build_filters { [] }

__PACKAGE__->meta->make_immutable;
