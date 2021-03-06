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

    # Dealing with croaks and wierd unexpected events.
    eval {
        my $result = $ps->create_project_skeleton();
    };
    if ($@) {
        return [
            500,
            ['content-type' => 'text/html'],
            ['<html><body>',
             '<h1>500 - Something wierd, but not entirely unexpected happended</h1>',
             '<tt style="display: block; background-color: #eee; margin: 12px; padding: 8px; border: 1px solid #888">',
             $@,
             '</tt>',
             '</body></html>',
            ],
        ];
        exit;
    }

    # Redirecting back to wiki when everything goes ok.
    return [
        303,
        [ 'Location'     => $ps->homepage->{url}, 
          'Content-Type' => 'text/plain' ], 
        [ "got data:\n" ]
    ];
};
