package Universa::Plugin::Lua51;

use Moose;
use Lua::API;
use Scalar::Util;
use Moose::Autobox;

with 'Universa::Role::Plugin';
with 'Universa::Role::EntityHandler';

with 'Universa::Role::Configuration' => {
    class      => 'Universa::plugin::Lua51::Config',
    configfile => 'lua51.yml',
};

has '_states' => (
    isa       => 'ArrayRef[Universa::Plugin::Lua51::Thread]',
    is        => 'ro',
    builder   => '_build_states',
    );


sub register_entity {
    my $self = shift;
    
    # TODO: change this stuff to be less static:
    my $thread = $self->_states->[0]->newthread;
	
    $thread->openlibs; # TODO: remove this
    $thread->gc( Lua::API::GCRESTART, 0);
    
    my $result = $thread->loadfile('lib/boot.lua');
    $thread->report($result);
    $result = $thread->resume(0);
    $thread->report($result);
    
    $thread->close;
}

sub _build_states {
    my $self = shift;
    
    my $luamain = Universa::Plugin::Lua51::Thread->new( _driver => $self );
    die "cannot create Lua state: not enough memory\n" unless defined $luamain;
    
    [$luamain];
}

__PACKAGE__->meta->make_immutable;

package Universa::Plugin::Lua51::Thread;

use Moose;

has 'progname' => (
    isa         => 'Str',
    is          => 'ro',
    default     => 'lua',
    lazy        => 1,
    );

has '_driver'   => (
    isa         => 'Universa::Plugin::Lua51',
    is          => 'ro',
    required    => 1,
    );

has 'L'         => (
    isa         => 'Lua::API::State',
    is          => 'ro',
    default     => sub { Lua::API::State->open },
    handles     => 'Universa::Plugin::Lua51::API',
    );


sub report {
    my ($self, $status) = @_;
    
    if ($status && !$self->isnil(-1)) {
	my $msg = $self->tostring(-1);
	$msg    = 'error: object is not a string!' unless defined $msg;
	$self->l_message($msg);
	$self->pop(1);
    }
    
    $status;
}

sub dofile {
    my ($self, $name) = @_;
    
    my $status = $self->loadfile($name) || $self->docall(0, 1);
    $self->report($status);
}

sub l_message {
    my ($self, $msg) = @_;

    
    print STDERR $self->progname . ': ' if defined $self->progname;
    print STDERR "$msg\n";
}

sub newthread {
    my $self = shift;

    my $T = $self->L->newthread;
    my $state = $self->new( _driver => $self->_driver, L => $T );
    $self->_driver->_states->push($state);
    $state; # Not sure if we need this, but just in case
}

sub dostring {
    my ($self, $string, $name) = @_;
    
    my $status = $self->loadbuffer($string, length($string), $name)
	|| $self->docall(0, 1);
    
    $self->report($status);
}

sub traceback {
    my $self = shift;
    
    return 1 if ($self->isstring(1));
    $self->L->getfield( Lua::API::GLOBALSINDEX, 'debug');
    
    if ($self->isstable(-1)) {
	$self->pop(1);
	return 1;
    }
    
    $self->getfield(-1, 'traceback');
    
    if (!$self->isfunction(-1)) {
	$self->pop(2);
	return 1;
    }
    
    $self->pushvalue(1);   # error message
    $self->pushinteger(2); # skip and traceback
    $self->call(2, 1);     # cal cebug & traceback
    return 1;
}

sub docall {
    my ($self, $narg, $clear) = @_;
    
    my $base = $self->gettop() - $narg;
    #$self->pushcfunction( \&_traceback );
    $self->insert($base);
    my $status = $self->pcall($narg, $clear ? 0 : Lua::API::MULTRET, $base);
    
    # Cleanup:
    $self->remove($base);
    $self->gc(Lua::API::GCCOLLECT, 0) if $status != 0; # GC if errors
    $status;
}

sub luainit {
    my $self = shift;

    return 0 unless defined $ENV{'LUA_INIT'};
    
    return $self->dofile($self, substr($ENV{'LUA_INIT'}, 1))
	if $ENV{'LUA_INIT'} =~ /^@/;

    $self->dostring($self, $ENV{'LUA_INIT'}, "=" . 'LUA_INIT');
}

__PACKAGE__->meta->make_immutable;

package Universa::Plugin::Lua51::API;

use Moose::Role;


# delegated Lua::API functions:
sub isnil       {}
sub pcall       {}
sub gc          {}
sub remove      {}
sub insert      {}
sub gettop      {}
sub pop         {}
sub pushinteger {}
sub pushvalue   {}
sub call        {}
sub getfield    {}
sub loadbuffer  {}
sub isstable    {}
sub loadfile    {}
sub tostring    {}
sub openlibs    {}
sub cpcall      {}
sub close       {}
sub resume      {}
sub getglobal   {}
sub is_function {}
sub register    {}

1;

package Universa::Plugin::Lua51::Config;

__DATA__
---
# Configuration for Universa::Plugin::Lua51
# TODO
test: undef
...
