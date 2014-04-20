package ObjectClone::Patcher;

use strict;
use warnings;

sub add_patch {
  my $self = shift;
  my ($apply_to, $patch) = @_;
  $self->{apply_to}->{$apply_to} ||= [];
  push @{$self->{apply_to}->{$apply_to}}, $patch;
  $self;
}

sub apply_patch {
  my $self = shift;
  MT->run_callbacks(ref($self) . '::before_apply_patch', $self);
  for my $apply_to (keys %{$self->{apply_to}}) {
    for my $patch (@{$self->{apply_to}->{$apply_to}}) {
      $self->{new_obj}->$apply_to($patch->($self->{new_obj}, $self->{orig_obj}));
    }
  }
}

sub id { undef }

sub new {
  my $class = shift;
  my ($new_obj, $orig_obj) = @_;
  my $param = {
    new_obj => $new_obj,
    orig_obj => $orig_obj,
  };
  my $self = bless $param, $class;
  my $pkey = $new_obj->properties->{primary_key};
  $self->add_patch($pkey => \&id);
}

sub model {
  my $class = shift;
  my $model = shift;
  return $class unless $model;

  my $mt_object_class = MT->model($model);
  return $class unless $mt_object_class;

  my $subclass = sprintf '%s::%s', __PACKAGE__, $mt_object_class;
  eval "require $subclass";
  die $@ if $@ && $@ !~ m!^\QCan't locate ObjectClone/Patcher/\E!ms;
  return $@ ? $class : $subclass;
}

sub remove_patch {
  my $self = shift;
  my ($apply_to, $patch) = @_;
  my $patches = $self->{apply_to}->{$apply_to};
  return $self unless @$patches;
  $self->{apply_to}->{$apply_to} = $patch ? [grep { $_ != $patch } @$patches] : [];
  $self;
}

1;
