#!/usr/bin/perl

use strict;
use warnings;

use lib qw(lib extlib t/lib);

use Test::More;

use MT::Test;

use_ok('MT::Tool::ObjectClone');

use_ok('ObjectClone::Patcher');
use_ok('ObjectClone::Patcher::CustomFields::Field');
use_ok('ObjectClone::Patcher::MT::Author');
use_ok('ObjectClone::Patcher::MT::Category');
use_ok('ObjectClone::Patcher::MT::Entry');

done_testing;
