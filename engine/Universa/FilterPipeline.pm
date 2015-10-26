package Universa::FilterPipeline;

use Moose;

has '_filters'   => (
    isa          => 'Universa::Attribute::FilterCollection',
    builder      => '_build_pipeline',
    lazy         => 1,
    handles      => {
	_put     => 'put',
	_get_one => 'get_one',
	
    },
    );


sub put {
    my ($self, $data) = @_;
    
    foreach my $layer ( @{ $self->_filters->types } ) {
	$self->_put($layer => $data);
    }
}

sub get {
    my ($self, $data) = @_;

    foreach my $layer ( @{ $self->_filters->types } ) {
	$self->_get_one($layer => $data);
    }
}

sub _build_pipeline {
    Universa::Attribute::FilterCollection->new(
	types => qw( IGate Proc Pres OGate Port ),
	);
}

__PACKAGE__->meta->make_immutable;
