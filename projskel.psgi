#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dump qw(pp);
use Log::Log4perl;
use Plack::Request;
use Confluence;
use Cwd;

# Log::Log4perl::init_and_watch('../../log4perl.conf', 10);

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $dir = getcwd;    
    my $logger = Log::Log4perl->get_logger('projskel');
    my $config = YAML::XS::LoadFile($dir.'/etc/config.yml');

    $logger->debug("Starting projskel");
    $logger->debug("Dumping config:");
    $logger->debug(pp($config));

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
    my $user = "";
    my $pass = "";
    my $wiki = Confluence->new($url, $user, $pass);


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
