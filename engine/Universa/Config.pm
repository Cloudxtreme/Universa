package Universa::Config;

use Moose;

with 'MooseX::SimpleConfig';

# Configuration file parameters:
has 'plugins'     => ( isa => 'ArrayRef[Str]', is  => 'ro' );
has 'subsystems'  => ( isa => 'ArrayRef[Str]', is  => 'ro' );
has 'name'        => ( isa => 'Str',           is  => 'ro' );
has 'description' => ( isa => 'Str',           is  => 'ro' );

__PACKAGE__->meta->make_immutable;

__DATA__
---
# Originally commented values are defaults within the engine itself.
# This file is in YAML format. Please see http://yaml.org/ fpr documentation.

# These plugins will automatically be loaded on startup by Universa:
plugins:
   - Universa::Plugin::PlayerSockets

# Subsystems are consumed by the core and provide the engine with additional
# features That would normally not be possible or considerably usable otherwise.
# It is advised to leave these alone unless you are very sure you know exactly 
# what you are doing:
subsystems:
   - Universa::PluginSystem    # Provides plugin management for Universa
   - Universa::DEMUX           # Handles demultiplexing of game library messages

# Some basic information about your game. You are going to want to change some
# of these before your project is released:
name:           My Game Name
description:    A really cool game that does things with stuff.
...
