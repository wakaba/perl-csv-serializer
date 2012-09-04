package CSV::Serializer;
use strict;
use warnings;
our $VERSION = '2.0';

# RFC 4180 text/csv

sub new {
    return bless {}, $_[0];
}

sub replace_newlines {
    if (@_ > 1) {
        $_[0]->{replace_newlines} = $_[1];
    }
    return $_[0]->{replace_newlines};
}

sub serialize_record {
    my ($class, $data) = @_;

    my $replace_newlines = ref $class ? $class->{replace_newlines} : 0;
    
    return join ',', map {
        if (/[\x00-\x1F\x22\x27,\x7F]/ or /^\x20/ or /\x20\z/) {
            my $v = $_;
            $v =~ s/\x22/\x22\x22/g;
            $v =~ s/\x0D\x0A?/ /g if $replace_newlines;
            $v =~ s/\x0A/ /g if $replace_newlines;
            '"' . $v . '"';
        } else {
            $_;
        }
    } @$data;
}

sub serialize_line {
    my $class = shift;
    return $class->serialize_record(@_) . "\x0D\x0A";
}

sub serialize_lines {
    my ($class, $data) = @_;
    return join '', map { $class->serialize_line($_) } @$data;
}

1;
