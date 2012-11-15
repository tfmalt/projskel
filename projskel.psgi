#!/usr/bin/env perl
use Data::Dump qw(pp);
use Log::Log4perl;
use Plack::Request;
use Confluence;

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    if ($req->method ne 'POST') {
        return [
            405, 
            [ 'Allow' => 'POST',
              'Content-Type' => 'text/plain' ],
            [ 'Method not allowed' ]
        ];
        exit;
    }
   
    my $url  = "http://wiki.startsiden.no:8080/rpc/xmlrpc";
    my $wiki = Confluence->new($url, 'thomas.malt', 'dtDe8N69k40vMK');

    my @parts = split('/', $req->parameters->{url});
    my $title = shift @parts;
    my $space = shift @parts;

    my $page = "";
    # $page = $wiki->getPage('IN', 'List of Project Document Templates');
    # my $page = $wiki->getPage($parts[1], 'test project');
    
    return [
        200,
        [ 'Content-Type' => 'text/plain' ], 
        [ "got data:\n", ref $file, "\n", 
          pp($req->parameters), "\n", 
          pp($env), "\n", ref($wiki), "\n",
          "title: ", $title, "  space: ", $space
        ]
    ];
};
