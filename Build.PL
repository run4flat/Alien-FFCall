use strict;
use warnings;

use Alien::Base::ModuleBuild;

my $builder = Alien::Base::ModuleBuild->new(
  'meta-spec' => {
    version => '2',
    url     => 'http://search.cpan.org/perldoc?CPAN::Meta::Spec',
  },
  module_name => 'Alien::FFCall',
  dist_abstract => 'Build and install libffcall',
  license => 'perl',
  configure_requires => {
    'Alien::Base' => 0,
  },
  requires => {
    'perl' => '5.8.1',
    'Alien::Base' => 0,
  },
  dist_author => 'David Mertens <dcmertens.perl@gmail.com>',
  alien_name => 'ffcall',
  alien_repository => {
    protocol => 'local',
    pattern  => qr/ffcall-([\d.]+)\.tar\.gz$/,
  },
  alien_build_commands => [
    '%pconfigure --prefix=%s --enable-shared', 
    'make',
    'make install'
  ],
  alien_provides_libs => '-lavcall -lcallback',
  resources => {
    bugtracker  => {
      web    => 'http://github.com/run4flat/Alien-FFCall/issues',
      mailto => 'dcmertens.perl@gmail.com',
    },
    repository  => {
      url  => 'git://github.com/run4flat/Alien-FFCall.git',
      web  => 'http://github.com/run4flat/Alien-FFCall',
      type => 'git',
    },
  },
);
$builder->create_build_script;
