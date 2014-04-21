#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib extlib t/lib);

use File::Basename;
use File::Spec;
use Test::More;

use MT::Test;
use ObjectClone::Patcher;

subtest 'Testing for ObjectClone::Patcher::model.' => sub {
  no warnings 'redefine';
  local *MT::Object::__properties = sub {
    { defaults => { id => 1, foo => 'foo' }, primary_key => 'id' };
  };
  local *MT::Object::has_column = sub { 1 };
  subtest 'When subclass is exist' => sub {
    my $patcher_class;
    $patcher_class = ObjectClone::Patcher->model('author');
    is($patcher_class, 'ObjectClone::Patcher::MT::Author', 'O::P::MT::Author is exist.');
    $patcher_class = ObjectClone::Patcher->model('category');
    is($patcher_class, 'ObjectClone::Patcher::MT::Category', 'O::P::MT::Category is exist.');
    $patcher_class = ObjectClone::Patcher->model('entry');
    is($patcher_class, 'ObjectClone::Patcher::MT::Entry', 'O::P::MT::Entry is exist.');
    $patcher_class = ObjectClone::Patcher->model('field');
    is($patcher_class, 'ObjectClone::Patcher::CustomFields::Field', 'O::P::CustomFields::Field is exist.');
  };

  subtest 'When subclass is not exist' => sub {
    my $patcher_class;
    $patcher_class = ObjectClone::Patcher->model('blog');
    is($patcher_class, 'ObjectClone::Patcher', 'O::P::MT::Blog is not exist.');
    $patcher_class = ObjectClone::Patcher->model('foo');
    is($patcher_class, 'ObjectClone::Patcher', 'O::P::MT::Foo is not exist.');
  };
};

subtest 'Testing for ObjectClone::Patcher::(add|remove)_patch and O::P::apply_patch' => sub {
  no warnings 'redefine';
  local *MT::Object::__properties = sub {
    { defaults => { id => 1, foo => 'foo' }, primary_key => 'id' };
  };
  local *MT::Object::has_column = sub { 1 };

  subtest 'When applied default patch' => sub {
    my $orig_obj = MT::Object->new;
    my $new_obj = $orig_obj->clone;
    my $patcher = ObjectClone::Patcher->new($new_obj, $orig_obj);
    $patcher->apply_patch;
    is($new_obj->id, undef, '$new_obj->id is equal to undef.');
    is($new_obj->foo, $orig_obj->foo, '$new_obj->foo is equal to $orig_obj->foo.');
  };

  subtest 'When add a patch and it applied' => sub {
    my $orig_obj = MT::Object->new;
    my $new_obj = $orig_obj->clone;
    my $patcher = ObjectClone::Patcher->new($new_obj, $orig_obj);
    my $patch = sub { 'bar' };
    $patcher->add_patch(foo => $patch);
    $patcher->apply_patch;
    isnt($new_obj->foo, $orig_obj->foo, '$new_obj->foo is not equal to $orig_obj->foo.');
  };

  subtest 'When add a patch and it remove and it applied.' => sub {
    my $orig_obj = MT::Object->new;
    my $new_obj = $orig_obj->clone;
    my $patcher = ObjectClone::Patcher->new($new_obj, $orig_obj);
    my $patch = sub { 'bar' };
    $patcher->add_patch(foo => $patch);
    $patcher->remove_patch(foo => $patch);
    $patcher->apply_patch;
    is($new_obj->foo, $orig_obj->foo, '$new_obj->foo is equal to $orig_obj->foo.');
  };

  subtest 'When adds multiple patch and they applied' => sub {
    my $orig_obj = MT::Object->new;
    my $new_obj = $orig_obj->clone;
    my $patcher = ObjectClone::Patcher->new($new_obj, $orig_obj);
    my $patch1 = sub { 'bar' };
    my $patch2 = sub { shift->foo . '_baz' };
    $patcher->add_patch(foo => $patch1)->add_patch(foo => $patch2);
    $patcher->apply_patch;
    is($new_obj->foo, 'bar_baz', '$new_obj->foo is applied multiple patches.');
  };

  subtest 'When adds multple patch and one remove and they applied.' => sub {
    my $orig_obj = MT::Object->new;
    my $new_obj = $orig_obj->clone;
    my $patcher = ObjectClone::Patcher->new($new_obj, $orig_obj);
    my $patch1 = sub { 'bar' };
    my $patch2 = sub { shift->foo . '_baz' };
    $patcher->add_patch(foo => $patch1)->add_patch(foo => $patch2);
    $patcher->remove_patch(foo => $patch1);
    $patcher->apply_patch;
    is($new_obj->foo, 'foo_baz', '$new_obj->foo is applied one patch.');
  };
};

subtest 'Testing for ObjectClone::Patcher::MT::Entry' => sub {
  subtest 'When applied default patch' => sub {
    no warnings 'redefine';
    my $orig_obj = MT::Entry->new;
    $orig_obj->set_values({
      id => 1,
      basename => 'foo',
      blog_id => 1,
    });
    local *MT::Util::make_unique_basename = sub { 'bar' };

    my $new_obj = $orig_obj->clone;
    my $patcher = ObjectClone::Patcher->model('entry')->new($new_obj, $orig_obj);
    $patcher->apply_patch;
    isnt($new_obj->basename, $orig_obj->basename,'$new_obj->basename is not equal to $orig_obj->basename.');
    isnt($new_obj->id, $orig_obj->id, '$new_obj->id is not equal to $orig_obj->id.');
  };
};

subtest 'Testing for ObjectClone::Patcher::MT::Author' => sub {
  subtest 'When applied default patch' => sub {
    no warnings 'redefine';
    my $orig_obj = MT::Author->new;
    $orig_obj->set_values({
      id => 1,
      basename => 'foo',
    });
    local *MT::Util::make_unique_author_basename = sub { 'bar' };
    my $new_obj = $orig_obj->clone;
    my $patcher = ObjectClone::Patcher->model('author')->new($new_obj, $orig_obj);
    $patcher->apply_patch;
    isnt($new_obj->basename, $orig_obj->basename,'$new_obj->basename is not equal to $orig_obj->basename.');
    isnt($new_obj->id, $orig_obj->id, '$new_obj->id is not equal to $orig_obj->id.');
  };
};

subtest 'Testing for ObjectClone::Patcher::MT::Category' => sub {
  subtest 'When applied default patch' => sub {
    no warnings 'redefine';
    my $orig_obj = MT::Category->new;
    $orig_obj->set_values({
      id => 1,
      basename => 'foo',
      nickname => 'foo',
    });
    local *MT::Util::make_unique_category_basename = sub { 'bar' };
    my $new_obj = $orig_obj->clone;
    my $patcher = ObjectClone::Patcher->model('category')->new($new_obj, $orig_obj);
    $patcher->apply_patch;
    isnt($new_obj->basename, $orig_obj->basename,'$new_obj->basename is not equal to $orig_obj->basename.');
    isnt($new_obj->id, $orig_obj->id, '$new_obj->id is not equal to $orig_obj->id.');
  };
};

subtest 'Testing for ObjectClone::Patcher::CustomFields::Field' => sub {
  subtest 'When applied default patch without catch exception' => sub {
    no warnings 'redefine';
    my $orig_obj = CustomFields::Field->new;
    $orig_obj->set_values({
      id => 1,
      basename => 'foo',
      tag => 'foo',
      blog_id => 1,
    });
    local *CustomFields::Field::validates_uniqueness_of_tag = sub { 1 };
    local *CustomFields::Field::make_unique_field_basename = sub { 'bar' };
    my $new_obj = $orig_obj->clone;
    my $patcher = ObjectClone::Patcher->model('field')->new($new_obj, $orig_obj);
    $patcher->apply_patch;
    isnt($new_obj->basename, $orig_obj->basename,'$new_obj->basename is not equal to $orig_obj->basename.');
    isnt($new_obj->id, $orig_obj->id, '$new_obj->id is not equal to $orig_obj->id.');
  };

  subtest 'When applied default patch with catch exception' => sub {
    no warnings 'redefine';
    no warnings 'once';
    my $orig_obj = CustomFields::Field->new;
    $orig_obj->set_values({
      id => 1,
      tag => 'foo',
    });
    local *CustomFields::Field::load = sub { $orig_obj };
    local *CustomFields::Field::make_unique_field_basename = sub {};
    my $new_obj = $orig_obj->clone;
    my $patcher = ObjectClone::Patcher->model('field')->new($new_obj, $orig_obj);
    my $errmsg;
    local $SIG{__DIE__} = sub { $errmsg = shift };
    eval { $patcher->apply_patch };
    like($errmsg, qr/^The template tag 'foo' is already in use in/, 'Catch die signal.');
  };
};

subtest 'Testing for ObjectClone::Patcher callback' => sub {
  subtest 'When called ObjectClone::Patcher::*::before_apply_patch callback' => sub {
    no warnings 'redefine';
    MT->add_callback('ObjectClone::Patcher::MT::Entry::before_apply_patch', 5, MT::Plugin->new, sub { $_[1]->add_patch('basename', sub { 'baz' }) });
    my $orig_obj = MT::Entry->new;
    $orig_obj->set_values({
      id => 1,
      basename => 'foo',
      blog_id => 1,
    });
    local *MT::Util::make_unique_basename = sub { 'bar' };
    my $new_obj = $orig_obj->clone;
    my $patcher = ObjectClone::Patcher->model('entry')->new($new_obj, $orig_obj);
    $patcher->apply_patch;
    is($new_obj->basename, 'baz','$new_obj->basename is equal to baz.');
  };
};

done_testing;
