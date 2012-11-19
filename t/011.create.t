use strict;
use warnings;

use Test::More;
use YAML::XS;
use File::Basename;
use Startsiden::Confluence::ProjectSkeleton;
use Data::Dump;
use Hash::MultiValue;

my $secret_file = dirname(__FILE__)."/secret.yml";
SKIP: {
    skip "No valid login secrets found.", 3 unless -f $secret_file; 

    my $params = Hash::MultiValue->new(
        path => "/display/BAC/XYZZY+Test+Project",
        host => "wiki.startsiden.no",
    );
    my $ps = Startsiden::Confluence::ProjectSkeleton->new(params => $params);
    isa_ok($ps, 'Startsiden::Confluence::ProjectSkeleton');

    my $secret = YAML::XS::LoadFile(dirname(__FILE__)."/secret.yml");

    $ps->config->{user} = $secret->{username};
    $ps->config->{pass} = $secret->{password};

    is ($ps->space, "BAC",                "got correct space");
    is ($ps->title, "XYZZY Test Project", "got correct title");

    dd($ps->config);
};

done_testing();
