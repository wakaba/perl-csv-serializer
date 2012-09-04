use strict;
BEGIN {
    my $dir_name = __FILE__; $dir_name =~ s{[^/\\]+$}{}; $dir_name ||= '.';
    unshift @INC, "$dir_name/../lib", glob "$dir_name/modules/*/lib";
}
use warnings;
use Test::More;
use Test::X1;
use CSV::Serializer;

test {
    my $c = shift;
    ok $CSV::Serializer::VERSION;
    done $c;
} n => 1;

for my $test (
    [[] => ''],
    [[qw/a b c/] => 'a,b,c'],
    [[qw/"" '""'/] => q{"""""","'""""'"}],
    [[',', ' a'] => '","," a"'],
    [["\x0D\x0A"] => qq{"\x0D\x0A"}],
    [['a '] => '"a "'],
    [["\x{3000}"] => qq{\x{3000}}],
) {
    test {
        my $c = shift;
        is +CSV::Serializer->serialize_record($test->[0]) => $test->[1];
        is +CSV::Serializer->serialize_line($test->[0]) => $test->[1] . "\x0D\x0A";
        done $c;
    } n => 2, name => ['serialize_record/line', @{$test->[0]}];
}

for my $test (
    [[] => ''],
    [[[]], => "\x0D\x0A"],
    [[[qw(a b c)], [qw(x y)]] => "a,b,c\x0D\x0Ax,y\x0D\x0A"],
) {
    test {
        my $c = shift;
        is +CSV::Serializer->serialize_lines($test->[0]), $test->[1];
        done $c;
    } n => 1, name => ['serialize_lines', @{$test->[0]}];
}

test {
    my $c = shift;
    my $csv = CSV::Serializer->new;
    $csv->replace_newlines(1);
    is $csv->serialize_lines([["aaa\x0D\x0Ab\x0Abb", ""], ["a\x0A", "\x0Dbb"]]),
        qq{"aaa b bb",\x0D\x0A"a "," bb"\x0D\x0A};
    done $c;
} n => 1, name => 'replace_newlines';

run_tests;
