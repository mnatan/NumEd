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
open my $file,  "<", shift,        or die "$!";
open my $dict,  "<", "dictionary", or die "$!";
open my $debug, ">", "debug.out",  or die "$!";

my @buffor  = <$file>;
my $line    = 0;
my $mode    = "NORMAL";
my $t9queue = "";
my @dictionary;
my @current_suggestions;
my $suggestion_iterator = 0;

while (<$dict>) {
    for my $hue (split) {
        push @dictionary, $hue;
    }
}

#say $debug Dumper(\@dictionary);

# --------------------- USER INTERFACE SECTION -----------------------
my $cui = new Curses::UI(-color_support => 1);

my @menu = (
    {
        -label   => 'File',
        -submenu => [
            {
                -label => 'Exit      ^Q',
                -value => \&exit_dialog
            }
        ]
    },
);

my $menu = $cui->add(
    'menu', 'Menubar',
    -menu => \@menu,
    -fg   => "Black",
);

my $win1 = $cui->add(
    'win1', 'Window',
    -y   => 1,
    -bfg => 'white',
);

my $indicator = $win1->add(
    "indicator", "TextViewer",
    -text => "$mode",
    -x    => $win1->width() - 20,
    -bfg  => 'white',
);

my $textfield = $win1->add(
    "textfield", "TextEditor",
    -text   => join("", @buffor),
    -pad    => 1,
    -border => 1,
);

# ----------------------- KEYBINDINGS SECTION --------------------------

# KEYPAD
$cui->set_binding(\&toggle_mode, "/");
$cui->set_binding(\&one,         "1");
$cui->set_binding(\&down,        "2");
$cui->set_binding(\&three,       "3");
$cui->set_binding(\&left,        "4");
$cui->set_binding(\&five,        "5");
$cui->set_binding(\&right,       "6");
$cui->set_binding(\&seven,       "7");
$cui->set_binding(\&up,          "8");
$cui->set_binding(\&nine,        "9");
$cui->set_binding(\&zero,        "0");
$cui->set_binding(\&plus,        "+");
$cui->set_binding(\&minus,       "-");
$cui->set_binding(\&comma,       ",");
$cui->set_binding(\&exit_dialog, "");

# OTHER
$cui->set_binding(sub { $menu->focus() }, "\cX");
$cui->set_binding(\&exit_dialog, "\cQ");
$cui->set_binding(sub { exit 0 }, "\cC");

# ----------------------- PROCEDURES SECTION ---------------------------
sub exit_dialog() {
    my $return = $cui->dialog(
        -message => "Are you sure you want to discard unsaved changes?",
        -title   => "Exit",
        -buttons => [ 'yes', 'no' ]
    );

    exit(0) if $return;
}

sub toggle_mode() {
    if ($mode eq "NORMAL") {
        $mode = "INPUT";
    } else {
        $mode = "NORMAL";
    }
    update_indicator();
}

sub update_indicator() {
    $indicator->text("$mode - $t9queue");
    $textfield->focus();
}

sub up() {
    if ($mode eq "NORMAL") {
        $textfield->cursor_up();
        $textfield->focus();
    } elsif ($mode eq "INPUT") {
        t9input("8");
    } elsif ($mode eq "MENU") {

    }
}

sub down() {
    if ($mode eq "NORMAL") {
        $textfield->cursor_down();
        $textfield->focus();
    } elsif ($mode eq "INPUT") {
        t9input("2");
    } elsif ($mode eq "MENU") {

    }
}

sub left() {
    if ($mode eq "NORMAL") {
        $textfield->cursor_left();
        $textfield->focus();
    } elsif ($mode eq "INPUT") {
        t9input("4");
    } elsif ($mode eq "MENU") {

    }
}

sub right() {
    if ($mode eq "NORMAL") {
        $textfield->cursor_right();
        $textfield->focus();
    } elsif ($mode eq "INPUT") {
        t9input("6");
    } elsif ($mode eq "MENU") {

    }
}

sub one() {
    if ($mode eq "NORMAL") {
        $line++ if $line + $textfield->height() < scalar @buffor;
        $textfield->text(
            join("", @buffor[ $line .. $line + $textfield->height() ]));
        $textfield->focus();
    } elsif ($mode eq "INPUT") {
        t9input("1");
    } elsif ($mode eq "MENU") {

    }
}

sub three() {
    if ($mode eq "NORMAL") {
        $line-- if $line;
        $textfield->text(
            join("", @buffor[ $line .. $line + $textfield->height() ]));
        $textfield->focus();
    } elsif ($mode eq "INPUT") {
        t9input("3");
    } elsif ($mode eq "MENU") {

    }
}

sub nine() {
    if ($mode eq "NORMAL") {

        #$textfield->cursor_end(); #no such subrutine?
        $textfield->focus();
    } elsif ($mode eq "INPUT") {
        t9input("9");
    } elsif ($mode eq "MENU") {
    }
}

sub seven() {
    if ($mode eq "NORMAL") {

        #$textfield->cursor_home(); #no such subrutine?
        $textfield->focus();
    } elsif ($mode eq "INPUT") {
        t9input("7");
    } elsif ($mode eq "MENU") {
    }
}

sub plus() {
    if ($mode eq "NORMAL") {
    } elsif ($mode eq "INPUT") {
        if ($suggestion_iterator + 1 < @current_suggestions) {
            $suggestion_iterator++;
        } else {
            $suggestion_iterator = 0;
        }
        t9input("");
    } elsif ($mode eq "MENU") {
    }
}

sub minus() {
    if ($mode eq "NORMAL") {
        $textfield->undo();
        $textfield->focus();
    } elsif ($mode eq "INPUT") {
        if ($suggestion_iterator - 1 > -@current_suggestions) {
            $suggestion_iterator--;
        } else {
            $suggestion_iterator = 0;
        }
        t9input("");
    } elsif ($mode eq "MENU") {
    }
}

sub five() {
    if ($mode eq "NORMAL") {
    } elsif ($mode eq "INPUT") {
        t9input("5");
    } elsif ($mode eq "MENU") {
    }
}

sub zero() {
    if ($mode eq "NORMAL") {
    } elsif ($mode eq "INPUT") {
        $t9queue = "";
        $textfield->add_string(" ");
        $textfield->focus();
        @buffor = split /(?<=\n)/, $textfield->get();
    } elsif ($mode eq "MENU") {
    }
}

sub comma() {
    $textfield->backspace();

    #pop $t9queue; #ERROR how to remove last char from string?
    $t9queue = substr($t9queue, 0, -1);    #hotfix cause no interents :( TODO
    $suggestion_iterator = 0;
    update_indicator();
    $textfield->focus();
}

sub t9input() {
    $textfield->backspace() for 1 .. length($t9queue);
    $t9queue .= shift;
    update_indicator();
    say $debug $t9queue;
    @current_suggestions = t9_find_words($t9queue, \@dictionary);
    say $debug Dumper(\@current_suggestions);
    if (@current_suggestions) {

        #buggy for 263? FIXME
        $textfield->add_string($current_suggestions[$suggestion_iterator]);
    } else {
        $textfield->add_string($t9queue);
    }
    $textfield->focus();
    @buffor = split /(?<=\n)/, $textfield->get();
}

our @T9NL = ('', '', 'ABC', 'DEF', 'GHI', 'JKL', 'MNO', 'PQRS', 'TUV', 'WXYZ');

sub t9_find_words($$) {
    my $num   = shift;
    my $words = shift;

    return () unless $num =~ /^[2-9]+$/;

    my $len = length($num);
    my $re;
    for (0 .. $len - 1) {
        $re .= "[" . $T9NL[ substr($num, $_, 1) ] . "]";
    }
    $re = "^$re\$";
    return grep { /$re/i } grep { length($_) == $len } @$words;
}

# -------------------- START MAIN LOOP --------------------------
$textfield->focus();
$cui->mainloop();

close $file;
close $debug;
