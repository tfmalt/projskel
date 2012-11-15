#!/usr/bin/env perl
use Data::Dump qw(pp);
use Log::Log4perl;
use Plack::Request;

my $app = sub {
    my $env = shift;
    # my $file = $env->{'psgi.input'};
    # my $data = undef;
    # read $file, $data, $env->{CONTENT_LENGTH};
    my $req = Plack::Request->new($env);

    return [
        200,
        [ 'Content-Type' => 'text/plain' ], 
        [ "got data:\n", ref $file, "\n", pp($req->parameters) ]
    ];
};
