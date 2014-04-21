package ObjectClone::Patcher::MT::Entry;

use strict;
use warnings;

use parent 'ObjectClone::Patcher';

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  $self->add_patch(basename => \&basename);
}

sub basename {
  MT::Util::make_unique_basename(shift);
}

1;
