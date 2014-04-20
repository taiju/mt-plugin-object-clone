package ObjectClone::Patcher::MT::Entry;

use strict;
use warnings;

use parent 'ObjectClone::Patcher';

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  $self->add_patch(basename    => \&basename)
       ->add_patch(category_id => \&category_id)
       ->add_patch(atom_id     => \&atom_id);
}

sub basename {
  MT::Util::make_unique_basename(shift);
}

sub category_id {
  my ($new_entry, $orig_entry) = @_;
  if ($new_entry->blog_id != $orig_entry->blog_id) {
    return undef;
  }
  $new_entry->category_id;
}

sub atom_id {
  my ($new_entry, $orig_entry) = @_;
  if ($new_entry->blog_id != $orig_entry->blog_id) {
    return $new_entry->make_atom_id;
  }
  $new_entry->atom_id;
}

1;
