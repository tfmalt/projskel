#!/usr/bin/env perl
use Data::Dump qw(pp);
use Log::Log4perl;
use Plack::Request;
use Confluence;

my $app = sub {
    my $env = shift;
    # my $file = $env->{'psgi.input'};
    # my $data = undef;
    # read $file, $data, $env->{CONTENT_LENGTH};
    
    my $req = Plack::Request->new($env);
    my $url = "http://wiki.startsiden.no:8080/rpc/xmlrpc";
    my $wiki = Confluence->new($url, 'thomas.malt', 'dtDe8N69k40vMK');

    if ($req->method ne 'POST') {
        return [
            405, 
            [ 'Allow' => 'POST',
              'Content-Type' => 'text/plain' ],
            [ 'Method not allowed' ]
        ];
        exit;
    }
    
    return [
        200,
        [ 'Content-Type' => 'text/plain' ], 
        [ "got data:\n", ref $file, "\n", 
          pp($req->parameters), 
          pp($env), "\n", ref($wiki) ]
    ];
};
