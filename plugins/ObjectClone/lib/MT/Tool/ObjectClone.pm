package MT::Tool::ObjectClone;

use strict;
use warnings;

use parent 'MT::Tool';

use MT;
use ObjectClone::Patcher;

my $mt = MT->instance;

my $amount = 1;
my ($debug, $model, $orig_id, @redefine, $verbose);

sub help {''}

sub main {
  my $self = shift;

  ($verbose) = $self->SUPER::main(@_);

  return $self->show_usage unless &_has_requires;

  my $class = $mt->model($model);
  die "$model is not exist model name." unless $class;

  my $pkey = $class->properties->{primary_key};
  my $orig_obj = $class->load($orig_id) or die $class->errstr;

  for (1..$amount) {
    my $new_obj = $orig_obj->clone;
    for my $pair (@redefine) {
      my ($key, $value) = split /=/, $pair;
      $new_obj->$key($value);
    }
    my $patcher = ObjectClone::Patcher->model($model)->new($new_obj, $orig_obj);
    $patcher->apply_patch;
    $new_obj->save or die $new_obj->errstr;
    printf "Made a clone of %s object (%s=%d).\n", $class, $pkey, $new_obj->$pkey;
    print MT::Util::YAML::Dump($new_obj->get_values) if $debug;
  }
}

sub options {
  ( 
    'amount=i'   => \$amount,
    'debug'      => \$debug,
    'model=s'    => \$model,
    'orig_id=i'  => \$orig_id,
    'redefine=s' => \@redefine,
  );
}

sub usage {
  my $usage = "\n\n"; 
  $usage .= <<'USAGE';
Requires:
  -m, --model=NAME      Model name (object datasource) of object to make clone.
  -o, --orig_id=NUM     Original object id clone object.

Options:
  -a, --amount=NUM      Amount of clones to make. Default 1.
  -d, --debug           Output debug info to STDERR.
  -h, --help            Show help.
  -r, --redefine=PAIR   Redefine column value with column key and column value pair.
  -u, --usage           Show usage.

Examples:
  # Make clones of 100 objects of MT::Entry from original entry that entry_id is 1.
  $ tools/object-clone --model=entry --orig_id=1 --amount=100

  # Make a clone of MT::Blog, and redefine name, site_path and site_url.
  $ tools/object-clone -m blog -o 2 -r 'name=Clone Blog' -r 'site_path=/path/to/site-path' -r 'site_url=/::/clone-blog/'
USAGE
}

sub _has_requires {
  $model && $orig_id;
}

1;
