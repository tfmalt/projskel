#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dump qw(pp);
use Log::Log4perl;
use Plack::Request;
use Confluence;
use File::Basename;
use Startsiden::Confluence::ProjectSkeleton; 

my $dir = dirname(__FILE__);    

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $logger = Log::Log4perl->get_logger('projskel');
    
    $logger->debug("Starting projskel");
    $logger->debug("Dumping env: " . pp($env));

    if ($req->method ne 'POST') {
        return [
            405, 
            [ 'Allow' => 'POST',
              'Content-Type' => 'text/plain' ],
            [ 'Method not allowed' ]
        ];
        exit;
    }
   
    my $ps = Startsiden::Confluence::ProjectSkeleton->new(
        logger => $logger,
        params => $req->parameters
    );

    $ps->create_project_skeleton();

    my $homepage          = $wiki->getPage($space, $title);
    my $homepage_template = $wiki->getPage(
        'BAC', 'Project Home Page Template'
    );

    $logger->debug('the homepage: ' . pp($homepage));
    $homepage->{content} = $homepage_template->{content};

    my $documentation = {
        space    => $space,
        title    => 'Documentation' . ' - ' . $homepage->{title} ,
        content  => '<ac:macro ac:name="tip"><ac:rich-text-body>
        <p>Add all project documentation under this space.</p></ac:rich-text-body></ac:macro>',
        parentId => $homepage->{id} 
    };
    $logger->debug('the data: '. pp($documentation));

    my $docs = $wiki->storePage($documentation);
    my $home = $wiki->storePage($homepage);

    my $plan = {
        space    => $space,
        title    => 'Project Plan - ' . $homepage->{title},
        parentId => $homepage->{id},
        content  => ''
    };

    my $mandate = {
        space    => $space,
        title    => 'Project Mandate - ' . $homepage->{title},
        parentId => $homepage->{id},
        content  => ''
    };

    $plan    = $wiki->storePage($plan);
    $mandate = $wiki->storePage($mandate);

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
