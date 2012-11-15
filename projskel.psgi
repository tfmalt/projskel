#!/usr/bin/env perl
use Data::Dump;

my $app = sub {
    my $env = shift;
    say dd($env);
    return [
        200,
        [ 'Content-Type' => 'text/plain' ], 
        [ "Hello World again\n", "foobar" ]
    ];
};
