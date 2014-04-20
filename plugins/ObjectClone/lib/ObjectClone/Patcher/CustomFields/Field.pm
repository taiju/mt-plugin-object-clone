package ObjectClone::Patcher::CustomFields::Field;

use strict;
use warnings;

use parent 'ObjectClone::Patcher';

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  $self->add_patch(basename => \&basename)
       ->add_patch(tag      => \&tag);
}

sub basename {
  shift->make_unique_field_basename;
}

sub tag {
  my $field = shift;
  my $eh = MT::ErrorHandler->new;
  unless ($field->validates_uniqueness_of_tag($eh)) {
    die MT::I18N::encode_text($eh->errstr, 'utf-8') unless $field->validates_uniqueness_of_tag($eh);
  }
  $field->tag;
}

1;
