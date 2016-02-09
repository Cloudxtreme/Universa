package Universa::Attribute::FilterCollection;

use Moose;
use Universa::Filter;
use MooseX::Params::Validate;


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

sub filters_by_stage {
    my ($self, $stage) = pos_validated_list(
	\@_,
	{ isa => 'Universa::Attribute::FilterCollection' },
	{ isa => 'Str' },
	);

    grep { $_->stage eq $stage } @{ $self->{_filters} };
}

__PACKAGE__->meta->make_immutable;
