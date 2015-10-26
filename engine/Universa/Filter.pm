package Universa::Filter;
# A much simpler and less pain filter system than Data::Transform..

use Moose;


# Overload these two:
sub put { @_[1 .. $#_] }
sub get { @_[1 .. $#_] }

__PACKAGE__->meta->make_immutable;
