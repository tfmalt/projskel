package Startsiden::Confluence::ProjectSkeleton;
use Moose;
use namespace::autoclean;
use File::Basename;
use Carp;
use YAML::XS;
use Data::Dump;

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

has 'logger' => (
	isa => 'Log::Log4perl::Logger',
	is  => 'rw',
); 

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

sub BUILD {
	my $self = shift;
	my $args = shift;
	
	dd($args) if $self->debug;
	
}

__PACKAGE__->meta->make_immutable;
1;
