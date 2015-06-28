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
use Data::Dumper;

# ----------------------- VARIABLES SECTION --------------------------
open my $file, "<", shift, or die "$!";
open my $debug, ">", "debug.out", or die "$!";

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

my $indicator = $win1->add("indicator", "TextViewer",
    -text => "$mode",
    -x => $win1->width()-10,
    -bfg => 'white',
);

my $textfield = $win1->add("textfield", "TextEditor",
    -text => join("", @buffor),
    -pad => 1,
    -border => 1,
    #-padtop => 2,
);

# ----------------------- KEYBINDINGS SECTION --------------------------

# KEYPAD
$cui->set_binding( \&toggle_mode , "/");
$cui->set_binding( \&up , "8");
$cui->set_binding( \&down , "2");
$cui->set_binding( \&left , "4");
$cui->set_binding( \&right , "6");
$cui->set_binding( \&one , "1");
$cui->set_binding( \&three , "3");
$cui->set_binding( \&seven , "7");
$cui->set_binding( \&nine , "9");
$cui->set_binding( sub{$textfield->backspace();$textfield->focus()}, ",");

# OTHER
$cui->set_binding( sub{ $menu->focus() }, "\cX");
$cui->set_binding( \&exit_dialog , "\cQ");
$cui->set_binding( sub{ exit 0 }, "\cC");

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

sub toggle_mode() 
{
    if ($mode eq "NORMAL") {
        $mode = "INPUT";
    } else {
        $mode = "NORMAL";
    }
    update_indicator();
}

sub update_indicator()
{
    $indicator->text($mode);
    $textfield->focus();
}

sub up() 
{
    if($mode eq "NORMAL"){
        $textfield->cursor_up();
        $textfield->focus();
    } elsif ($mode eq "INPUT"){
        $textfield->add_string("8");
        $textfield->focus();
        @buffor = split /(?<=\n)/, $textfield->get();
    } elsif ($mode eq "MENU"){

    }
}

sub down() 
{
    if($mode eq "NORMAL"){
        $textfield->cursor_down();
        $textfield->focus();
    } elsif ($mode eq "INPUT"){
        $textfield->add_string("2");
        $textfield->focus();
        @buffor = split /(?<=\n)/, $textfield->get();
    } elsif ($mode eq "MENU"){

    }
}

sub left() 
{
    if($mode eq "NORMAL"){
        $textfield->cursor_left();
        $textfield->focus();
    } elsif ($mode eq "INPUT"){
        $textfield->add_string("4");
        $textfield->focus();
        @buffor = split /(?<=\n)/, $textfield->get();
    } elsif ($mode eq "MENU"){

    }
}

sub right() 
{
    if($mode eq "NORMAL"){
        $textfield->cursor_right();
        $textfield->focus();
    } elsif ($mode eq "INPUT"){
        $textfield->add_string("6");
        $textfield->focus();
        @buffor = split /(?<=\n)/, $textfield->get();
    } elsif ($mode eq "MENU"){

    }
}
sub one() 
{
    if($mode eq "NORMAL"){
        $line++ if $line+$textfield->height() < scalar @buffor;
        $textfield->text(join("",@buffor[$line..$line+$textfield->height()]));
        $textfield->focus();
    } elsif ($mode eq "INPUT"){
        $textfield->add_string("1");
        $textfield->focus();
        @buffor = split /(?<=\n)/, $textfield->get();
    } elsif ($mode eq "MENU"){

    }
}
sub three() 
{
    if($mode eq "NORMAL"){
        $line-- if $line;
        $textfield->text(join("",@buffor[$line..$line+$textfield->height()]));
        $textfield->focus();
    } elsif ($mode eq "INPUT"){
        $textfield->add_string("3");
        $textfield->focus();
        @buffor = split /(?<=\n)/, $textfield->get();
    } elsif ($mode eq "MENU"){

    }
}
sub nine() 
{
    if($mode eq "NORMAL"){
    } elsif ($mode eq "INPUT"){
        $textfield->add_string("9");
        $textfield->focus();
        @buffor = split /(?<=\n)/, $textfield->get();
    } elsif ($mode eq "MENU"){
    }
}
sub seven() 
{
    if($mode eq "NORMAL"){
    } elsif ($mode eq "INPUT"){
        $textfield->add_string("7");
        $textfield->focus();
        @buffor = split /(?<=\n)/, $textfield->get();
    } elsif ($mode eq "MENU"){
    }
}

# -------------------- START MAIN LOOP --------------------------
$textfield->focus();
$cui->mainloop();

close $file;
close $debug;
