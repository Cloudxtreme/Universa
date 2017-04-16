package Universa::Role::FilterPipeline;

use MooseX::Role::Parameterized;
use Universa::Attribute::FilterCollection;

parameter stages => ( isa => 'ArrayRef[Str]', required => 1 );
parameter store  => ( isa => 'Str', default => '_filters' );

role {
    my $p = shift;
    requires 'BUILD';
    
    has $p->store  => (
	isa        => 'Universa::Attribute::FilterCollection',
	builder    => '_build_filters',
	handles    => {
	    filters_by_stage => 'filters_by_stage',
	    add_filter => 'add',
	    filters    => 'filters',
	},
	);

    method '_build_filters' => sub {
	Universa::Attribute::FilterCollection->new;
    };

    method 'put' => sub {
	my ($self, $data) = @_;
	
	foreach my $stage ( @{ $p->stages } ) {
	    foreach my $filter ( $self->filters_by_stage($stage) ) {
		$data = $filter->put($data);
	    }
	}

	$data;
    };

    method 'get' => sub {
	my ($self, $data) = @_;

	foreach my $stage ( reverse @{ $p->stages } ) {
	    foreach my $filter ( $self->filters_by_stage($stage) ) {
		$data = $filter->get($data);
	    }
	}

	$data;
    };

    method 'add_filter' => sub {
	my $self = shift;

	
    };
};
