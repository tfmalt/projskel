package Startsiden::Confluence::ProjectSkeleton;

use Moose;
use namespace::autoclean;
use File::Basename;
use Carp;
use YAML::XS;
use Data::Dump;
use Confluence;

has 'config' => (
	isa     => 'HashRef',
	is      => 'ro',
	lazy    => 1,
	builder => '_load_config',
);

has 'debug' => (
	isa => 'Bool',
	is  => 'ro',
	lazy => 1,
	default => sub { return (defined $ENV{DEBUG} && $ENV{DEBUG} == 1) }
);

has 'wiki' => (
    isa     => 'Confluence',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_wiki',
);

has 'params' => (isa => 'Hash::MultiValue', is => 'ro', required => 1);
has 'logger' => (isa => 'Log::Log4perl::Logger', is  => 'rw'); 

has 'space' => (
    isa  => 'Str', 
    is   => 'ro', 
    lazy => 1,
    builder => '_fetch_space' ,
);

has 'title' => (
    isa => 'Str',
    is  => 'ro',
    lazy => 1,
    builder => '_fetch_title',
);

sub _fetch_space {
    my $self = shift;

    my @parts = split('/', $self->params->{path});
    return $parts[-2];
}

sub _fetch_title {
    my $self = shift;
    
    my @parts = split('/', $self->params->{path});
    my $title = $parts[-1];
    
    $title =~ s/\+/ /g;

    return $title;
}

sub _load_config {
	my $self = shift;

	my $dir  = dirname(__FILE__)."/../../../etc";
	my $file = $dir."/config.yml";

	print "DEBUG file: ", $file, "\n" if ($self->debug); 

	if (! -f $file) {
		croak("Could not find config file: $file");
	}
	my $config = YAML::XS::LoadFile($file);
	return $config;;
}

sub _build_wiki {
    my $self = shift;

    my $conf = $self->config;
    my $wiki = Confluence->new($conf->{rpcurl}, $conf->{user}, $conf->{pass});
    
    return $wiki;
}

sub create_project_skeleton {
    my $self = shift;

    $self->update_homepage();
}

sub update_homepage {
    my $self = shift;

    my $w    = $self->wiki;
    my $c    = $self->config;

    my $home      = $w->getPage($self->space, $self->title);
    my $home_tmpl = $w->getPage($c->{template_space}, $c->{templates}->{homepage}); 
    
    return 1;
}

__PACKAGE__->meta->make_immutable;
1;
