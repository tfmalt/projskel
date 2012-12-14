use strict;
use warnings;

use Test::More;
use YAML::XS;
use File::Basename;
use Startsiden::Confluence::ProjectSkeleton;
use Data::Dump;
use Hash::MultiValue;


my $params = Hash::MultiValue->new(
    path => "/display/BAC/XYZZY+Test+Project",
    host => "wiki.startsiden.no",
    projectlead => "Thomas Malt",
    projectowner => "Malt Thomas",
);

my $ps = Startsiden::Confluence::ProjectSkeleton->new(params => $params);
isa_ok($ps, 'Startsiden::Confluence::ProjectSkeleton');

$ps->homepage({title => "Dette er en fin tittel for test"});
my $data = $ps->handle_mandate({
    content => "##project_name## -- ##project_owner## -- ##project_lead##"
});
is($data->{content}, "Dette er en fin tittel for test -- Malt Thomas -- Thomas Malt",
    "verifying correct variable substitution in handle_mandate"
);

is ($ps->space, "BAC",                "got correct space");
is ($ps->title, "XYZZY Test Project", "got correct title");

my $secret_file = dirname(__FILE__)."/secret.yml";

SKIP: {
    skip "No valid login secrets found.", 3 unless -f $secret_file; 

    my $secret = YAML::XS::LoadFile($secret_file);

    $ps->config->{user} = $secret->{username};
    $ps->config->{pass} = $secret->{password};

    my $result = $ps->create_project_skeleton();
    ok($result);
};


done_testing();
