package ObjectClone::Patcher::MT::Author;

use strict;
use warnings;

use parent 'ObjectClone::Patcher';

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  $self->add_patch(basename => \&basename);
}

sub basename {
  MT::Util::make_unique_author_basename(shift);
}

1;
