package Universa::Message;

use Moose;
use Moose::Util qw(apply_all_roles);

has '_workload'  => (
    isa          => 'HashRef[Any]',
    is           => 'ro',
    lazy         => 1,
    );

has 'serializer' => (
    isa          => 'Str',
    is           => 'ro',
    default      => 'Universa::Role::JSONMessage',
    );

has 'type'       => (
    isa          => 'Str',
    is           => 'ro',
    required     => 1,
    );


sub BUILD {
    my $self = shift;
    my $serializer = $self->serializer;
    my $type       = "Universa::Role::Message::@{ [$self->type] }";

    apply_all_roles($self, [$serializer, $type]);
}

# TODO

__PACKAGE__->meta->make_immutable;
