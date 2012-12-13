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
	is      => 'rw',
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

has 'homepage' => ( isa => 'HashRef', is  => 'rw' );

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

    my $c    = $self->config;
    my $w    = $self->wiki;
    my $ts   = $c->{template_space};
    my $templates  = $c->{templates};
 
    if (ref($templates) ne 'HASH') {
        croak "templates list from config is not an hash. syntax error.";
    }

    if (!defined $templates->{homepage}) {
        croak "homepage template not defined. syntax error.";
    }
    
    # Create and set the root page of the project    
    $self->create_project_homepage();

    for my $key (keys %{$templates}) {
        next if ($key eq 'homepage');
        $self->create_page_from_template($key);
    }
 
    return 1;
}

sub create_project_homepage {
    my $self = shift;

    my $w  = $self->wiki;
    my $c  = $self->config;
    my $ts = $c->{template_space};

    # Create and set the root page of the project    
    my $root = $w->getPage($self->space, $self->title);
    my $tmpl = $w->getPage($ts, $c->{templates}->{homepage}->{name});

    $root->{content} = $tmpl->{content};
    $c->{templates}->{homepage}->{id}    = $root->{id};
    $c->{templates}->{homepage}->{title} = $root->{title}; 
    $w->storePage($root);
    $self->homepage($root);

    return 1;
}

sub get_parent_id {
    my ($self, $key) = @_;

    my $c      = $self->config;
    my $parent = $c->{templates}->{$key}->{parent};

    return $c->{templates}->{$parent}->{id}; 
}

sub set_page_id {
    my ($self, $key, $id) = @_;

    my $c = $self->config;
    # TODO add assertions haha.
    $c->{templates}->{$key}->{id} = $id;

    return 1;
}

sub create_page_from_template {
    my $self = shift;
    my $key  = shift;
 
    my $w    = $self->wiki;
    my $c    = $self->config;
    my $ts   = $c->{template_space};
    my $name = $c->{templates}->{$key}->{name};
    my $tmpl = $w->getPage($ts, $name); 

    my $page = {
        space    => $self->space,
        title    => $c->{templates}->{$key}->{title} . ' - ' 
                  . $c->{templates}->{homepage}->{title},
        content  => $tmpl->{content},
        parentId => $self->get_parent_id($key),
    };

    $page = $w->storePage($page);
    $self->set_page_id($key, $page->{id});
    
    return 1;
}

__PACKAGE__->meta->make_immutable;
1;
