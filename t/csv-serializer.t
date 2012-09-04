package test::CSV::Serializer;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::More;
use CSV::Serializer;

sub _version : Test(1) {
    ok $CSV::Serializer::VERSION;
}

sub _serialize_line : Test(14) {
    my $class = 'CSV::Serializer';
    
    for (
        [[] => ''],
        [[qw/a b c/] => 'a,b,c'],
        [[qw/"" '""'/] => q{"""""","'""""'"}],
        [[',', ' a'] => '","," a"'],
        [["\x0D\x0A"] => qq{"\x0D\x0A"}],
        [['a '] => '"a "'],
        [["\x{3000}"] => qq{\x{3000}}],
    ) {
        is $class->serialize_record($_->[0]) => $_->[1];
        is $class->serialize_line($_->[0]) => $_->[1] . "\x0D\x0A";
    }
}

sub _serialize_lines : Test(3) {
    my $class = 'CSV::Serializer';
    
    for (
        [[] => ''],
        [[[]], => "\x0D\x0A"],
        [[[qw(a b c)], [qw(x y)]] => "a,b,c\x0D\x0Ax,y\x0D\x0A"],
    ) {
        is $class->serialize_lines($_->[0]), $_->[1];
    }
}

sub _replace_newlines : Test(1) {
    my $csv = CSV::Serializer->new;
    $csv->replace_newlines(1);
    is $csv->serialize_lines([["aaa\x0D\x0Ab\x0Abb", ""], ["a\x0A", "\x0Dbb"]]),
        qq{"aaa b bb",\x0D\x0A"a "," bb"\x0D\x0A};
}

__PACKAGE__->runtests;

1;
