use strict;
use warnings;

use Test::More;
use Hash::MultiValue;
use File::Basename;

BEGIN {
    use_ok( 'Startsiden::Confluence::ProjectSkeleton' );
}

my $ps = undef;
eval {
    $ps = Startsiden::Confluence::ProjectSkeleton->new();
};
ok($@ =~ /Attribute \(params\) is required/, "Test eval dies on missing params");

eval {
    $ps = Startsiden::Confluence::ProjectSkeleton->new(params => {});
};
ok($@ =~ /Hash::MultiValue/, "Test eval dies on wrong datatype for params");

my $params = Hash::MultiValue->new(
    path => "/display/BAC/XYZZY+Test+Project",
    host => "wiki.startsiden.no",
);

$ps = Startsiden::Confluence::ProjectSkeleton->new(params => $params);
isa_ok($ps, 'Startsiden::Confluence::ProjectSkeleton');

is($ps->config->{user}, "username", "username");
is($ps->config->{pass}, "password", "password");
is($ps->config->{rpcurl}, "http://wiki.startsiden.no:8080/rpc/xmlrpc", "rpcurl");

done_testing();

