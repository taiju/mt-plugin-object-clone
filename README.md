# NAME

ObjectClone - Provide a tool for to make clone of MT objects.

# INSTLATION

1. Copy from `mt-plugin-object-clone/plugins/ObjectClone` to `/path/to/mt/plugins/ObjectClone`.
2. Copy from `mt-plugin-object-clone/tools/object-clone` to `/path/to/mt/tools/object-clone`.

# USAGE

```
USAGE: perl tools/object-clone --model=NAME --orig_id=NUM [OPTION]

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
```

# CALLBACK

Callback plugin sample code.

```
id: ObjectCloneCallback
key: object-clone-callback
name: ObjectCloneCallback
callbacks:
  ObjectClone::Patcher::MT::Entry::before_apply_patch: |
    sub {
      my ($cb, $patcher) = @_;
      $patcher->add_patch('basename', sub {
        my ($new_obj, $orig_obj) = @_;
        'new-basename';
      });
    }
```

## What's ObjectClone::Patcher ?

ObjectClone::Patcher is patch interface for tools/object-clone.

For example, they modify of clone object basename to unique basename.

ObjectClone plugin has patcher class below.

- ObjectClone::Patcher::MT::Entry
- ObjectClone::Patcher::MT::Category
- ObjectClone::Patcher::MT::Author
- ObjectClone::Patcher::CustomFields::Field

# LICENSE

Copyright (C) 2014 taiju.

MIT license.

# AUTHOR

taiju <higashi@taiju.info>
