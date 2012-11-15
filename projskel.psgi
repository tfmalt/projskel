#!/usr/bin/env perl
use Data::Dump qw(pp);
use Log::Log4perl;
use Plack::Request;
use Confluence;

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    $req->logger({ level => 'autospawner', 'message' => "Starting projskel" });
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
    my ($space, $title) = @parts[-2, -1];
    $title =~ s/\+/ /g; # need to wash urlencoding to make titles work
    # my $page = "";
    # $page = $wiki->getPage('IN', 'List of Project Document Templates');
    my $homepage          = $wiki->getPage($space, $title);
    my $homepage_template = $wiki->getPage(
        'BAC', 'Project Home Page Template'
    );

    $project_url = $homepage->{url};
    $homepage->{content} = $homepage_template->{content};
    $wiki->storePage($homepage);

    return [
        303,
        [ 'Location'     => $project_url, 
          'Content-Type' => 'text/plain' ], 
        [ "got data:\n", "logger: ", 
          pp($req->parameters), "\n", 
          pp($env), "\n", ref($wiki), "\n",
          "title: ", $title, "  space: ", $space, "\n",
          pp($homepage), pp($homepage_template)
        ]
    ];
};
