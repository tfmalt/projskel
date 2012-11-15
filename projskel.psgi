#!/usr/bin/env perl
use Data::Dump;

my $app = sub {
    my $env = shift;

    return [
        200,
        [ 'Content-Type' => 'text/plain' ], 
        [ "Hello World again\n", "foobar", dd($env) ]
    ];
};
