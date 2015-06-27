#! /usr/bin/env perl

#
# Short description for numed.pl
#
# Author Marcin Natanek <natanek.marcin@gmail.com>
# Version 0.1
# Copyright (C) 2015 Marcin Natanek <natanek.marcin@gmail.com>
# Modified On 2015-06-28 00:27
# Created  2015-06-28 00:27
#

use v5.20;
use warnings;
use autodie;

use Curses::UI;
my $cui = new Curses::UI( -color_support => 1 );

my @menu = (
    { -label => 'File', 
        -submenu => [
            { 
                -label => 'Exit      ^Q', 
                -value => \&exit_dialog  
            }
        ]
    },
);

sub exit_dialog()
{
    my $return = $cui->dialog(
        -message   => "Do you really want to quit?",
        -title     => "Are you sure???", 
        -buttons   => ['yes', 'no']
    );

    exit(0) if $return;
}

my $menu = $cui->add(
    'menu','Menubar', 
    -menu => \@menu,
    -fg  => "Black",
);

my $win1 = $cui->add(
    'win1', 'Window',
    -border => 1,
    -y    => 1,
    -bfg  => 'white',
);

$cui->set_binding(sub {$menu->focus()}, "\cX");
$cui->set_binding( \&exit_dialog , "\cQ");
$cui->set_binding( sub{ exit 0 }, "\cC");
$cui->set_binding( \&up , "8");
$cui->set_binding( \&down , "2");

open my $file, "<", shift, or die "$!";

my @buffor = <$file>;
my $line = 0;
my $height = 20;

my $texteditor = $win1->add("text", "TextEditor",
    -text => "@buffor[$line..$line+$height]"
);

sub up() 
{
    $line-- if $line;
    $texteditor->text("@buffor[$line..$line+$height]");
}

sub down() 
{
    $line++ if $line+$height < scalar @buffor;
    $texteditor->text("@buffor[$line..$line+$height]");
}

#my $progressbar = $win1->add(
#'myprogressbar', 'Progressbar',
#-max       => 250,
#-pos       => 42,
#);

#$progressbar->draw;

$texteditor->focus();
$cui->mainloop();
