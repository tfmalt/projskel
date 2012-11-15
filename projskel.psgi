#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dump qw(pp);
use Log::Log4perl;
use Plack::Request;
use Confluence;

Log::Log4perl::init_and_watch('../../log4perl.conf', 10);

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    
    my $logger = Log::Log4perl->get_logger('projskel');

    $logger->debug("Starting projskel");

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
    $logger->debug('the homepage: ' . pp($homepage));
    # $project_url = $homepage->{url};
    $homepage->{content} = $homepage_template->{content};

    my $documentation = {
        space    => $space,
        title    => 'Documentation' . ' - ' . $homepage->{title} ,
        content  => '<ac:macro ac:name="tip"><ac:rich-text-body>
        <p>Give this page the same name as the project</p></ac:rich-text-body></ac:macro><ac:macro ac:name="info"><ac:rich-text-body>',
        parentId => $homepage->{id} 
    };
    $logger->debug('the data: '. pp($documentation));

    my $docs = $wiki->storePage($documentation);
    
    my $home = $wiki->storePage($homepage);

    return [
        303,
        [ 'Location'     => $homepage->{url}, 
          'Content-Type' => 'text/plain' ], 
        [ "got data:\n", "logger: ", 
          pp($req->parameters), "\n", 
          pp($env), "\n", ref($wiki), "\n",
          "title: ", $title, "  space: ", $space, "\n",
          pp($homepage), pp($homepage_template)
        ]
    ];
};
