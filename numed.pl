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

# ----------------------- VARIABLES SECTION --------------------------
open my $file, "<", shift, or die "$!";

my @buffor = <$file>;
my $line = 0;
my $mode = "NORMAL";

# --------------------- USER INTERFACE SECTION -----------------------
my $cui = new Curses::UI( 
    -color_support => 1 
);

my @menu = (
    { 
        -label => 'File', 
        -submenu => [
            { 
                -label => 'Exit      ^Q', 
                -value => \&exit_dialog  
            }
        ]
    },
);

my $menu = $cui->add(
    'menu','Menubar', 
    -menu => \@menu,
    -fg  => "Black",
);

my $win1 = $cui->add(
    'win1', 'Window',
    -y    => 1,
    -bfg  => 'white',
);

my $texteditor = $win1->add("text", "TextEditor",
    -text => "@buffor",
    -pad => 1,
);

# ----------------------- KEYBINDINGS SECTION --------------------------
$cui->set_binding( sub{ $menu->focus() }, "\cX");
$cui->set_binding( \&exit_dialog , "\cQ");
$cui->set_binding( sub{ exit 0 }, "\cC");
$cui->set_binding( \&up , "8");
$cui->set_binding( \&down , "2");

# ----------------------- PROCEDURES SECTION ---------------------------
sub exit_dialog()
{
    my $return = $cui->dialog(
        -message   => "Are you sure you want to discard unsaved changes?",
        -title     => "Exit", 
        -buttons   => ['yes', 'no']
    );

    exit(0) if $return;
}

sub up() 
{
    if($mode eq "NORMAL"){
        $line-- if $line;
        $texteditor->text("@buffor[$line..$line+$texteditor->height()]");
    }
}

sub down() 
{
    if($mode eq "NORMAL"){
        $line++ if $line+$texteditor->height() < scalar @buffor;
        $texteditor->text("@buffor[$line..$line+$texteditor->height()]");
    }
}

# -------------------- START MAIN LOOP --------------------------
$texteditor->focus();
$cui->mainloop();
