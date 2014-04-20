#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib extlib t/lib);

BEGIN {
  $ENV{MT_CONFIG} = 'mysql-test.cfg';
}

use Test::More;

use MT::Test qw(:db :data);
use MT::Tool::ObjectClone;

subtest 'Run main method' => sub {
  subtest '--model=entry --orig_id=1' => sub {
    my $orig_obj = MT::Entry->load(1);
    `perl tools/object-clone --model=entry --orig_id=1`; 
    my $new_obj = MT::Entry->load(undef, { limit => 1, sort => 'id', direction => 'descend' });
    is($new_obj->id, 24, '$new_obj->id is equal to 24.');
  };

  subtest '--model=entry --orig_id=1 --amount=6' => sub {
    my $orig_obj = MT::Entry->load(1);
    `perl tools/object-clone --model=entry --orig_id=1 --amount=6`; 
    my $new_obj = MT::Entry->load(30);
    is($new_obj->id, 30, '$new_obj->id is equal to 30.');
  };

  subtest '--model=entry --orig_id=1 --redefine=title=foo' => sub {
    my $orig_obj = MT::Entry->load(1);
    `perl tools/object-clone --model=entry --orig_id=1 --redefine=title=foo`; 
    my $new_obj = MT::Entry->load(undef, { limit => 1, sort => 'id', direction => 'descend' });
    isnt($new_obj->title, $orig_obj->title, '$new_obj->title is not equal to $orig_obj->title.');
  };
};

done_testing;
