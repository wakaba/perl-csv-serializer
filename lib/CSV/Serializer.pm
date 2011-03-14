package CSV::Serializer;
use strict;
use warnings;
our $VERSION = '1.0';

# RFC 4180 text/csv

sub serialize_record {
    my ($class, $data) = @_;
    
    return join ',', map {
        if (/[\x00-\x1F\x22\x27,\x7E]/ or /^\x20/ or /\x20\z/) {
            my $v = $_;
            $v =~ s/\x22/\x22\x22/g;
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
