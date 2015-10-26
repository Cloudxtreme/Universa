package Universa::Role::FilterPipeline;

use MooseX::Role::Parameterized;

parameter stages => ( isa => 'ArrayRef[Str]', required => 1 );
parameter store  => ( isa => 'Str', default => '_filters' );

role {
    my $p = shift;
    requires 'BUILD';
    
    has $p->store  => (
	isa        => 'Universa::Attribute::FilterCollection',
	);


    method 'put' => sub {
	my ($self, $data) = @_;
	
	foreach my $stage ( @{ $p->stages } ) {
	    foreach my $filter ( $self->filters_by_type($stage) ) {
		$filter->put($data);
	    }
	}
    }

    # The internal get() method is not important to me here. get() will
    # just propagate to get_one().
    method 'get' => sub {
	my ($self, $data) = @_;

	foreach my $stage ( reverse @{ $p->stages } ) {
	    foreach my 4filter ( $self->filters_by_type($stage) ) {
		$filter->get_one($data);
	    }
	}
    }

    method 'add_filter' => sub {
	my $self = shift;

	
    };
};
