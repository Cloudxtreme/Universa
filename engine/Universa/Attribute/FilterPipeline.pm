package Universa::Attribute::FilterPipeline;

use Moose;

has '_filters' => (
    isa        => 'HashRef[ArrayRef[Universa::Attribute::FilterCollection]|Undef]',
    traits     => [ 'Hash' ],
    lazy       => 1,
    builder    => '_build_filters',
    );

sub _build_filters { {} },


__PACKAGE__->meta->make_immutable;
