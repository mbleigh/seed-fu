Seed Fu
=======

Seed Fu is an attempt to once and for all solve the problem of inserting and maintaining seed data in a database. It uses a variety of techniques gathered from various places around the web and combines them to create what is hopefully the most robust seed data system around.

Warning: API Changes
--------------------

Version 2.0.0 of Seed Fu introduced API changes. `Seed::Writer` was been completely overhauled and will require you to update your scripts. Some other deprecations were introduced, and support is fully removed in version 2.1.0. Please see the [CHANGELOG](CHANGELOG.md) for details.

The API documentation is available in full at [http://rubydoc.info/github/mbleigh/seed-fu/master/frames](http://rubydoc.info/github/mbleigh/seed-fu/master/frames).

Basic Example
-------------

### In `db/fixtures/users.rb`

    User.seed do |s|
      s.id    = 1
      s.login = "jon"
      s.email = "jon@example.com"
      s.name  = "Jon"
    end

    User.seed do |s|
      s.id    = 2
      s.login = "emily"
      s.email = "emily@example.com"
      s.name  = "Emily"
    end

### To load the data:

    $ rake db:seed_fu
    == Seed from /path/to/app/db/fixtures/users.rb
     - User {:id=>1, :login=>"jon", :email=>"jon@example.com", :name=>"Jon"}
     - User {:id=>2, :login=>"emily", :email=>"emily@example.com", :name=>"Emily"}

Installation
------------

### Rails 3.1, 3.2, 4.0, 4.1, 4.2, 5.0

Just add `gem 'seed-fu', '~> 2.3'` to your `Gemfile`

Seed Fu depends on Active Record, but doesn't have to be used with a full Rails app. Simply load and require the `seed-fu` gem and you're set.

### Rails 3.0

The current version is not backwards compatible with Rails 3.0. Please use `gem 'seed-fu', '~> 2.0.0'`.

### Rails 2.3

The current version is not backwards compatible with Rails 2.3. Please use `gem 'seed-fu', '~> 1.2.0'`.

Constraints
-----------

Constraints are used to identify seeds, so that they can be updated if necessary. For example:

    Point.seed(:x, :y) do |s|
      s.x = 4
      s.y = 7
      s.name = "Home"
    end

The first time this seed is loaded, a `Point` record will be created. Now suppose the name is changed:

    Point.seed(:x, :y) do |s|
      s.x = 4
      s.y = 7
      s.name = "Work"
    end

When this is run, Seed Fu will look for a `Point` based on the `:x` and `:y` constraints provided. It will see that a matching `Point` already exists and so update its attributes rather than create a new record.

If you do not want seeds to be updated after they have been created, use `seed_once`:

    Point.seed_once(:x, :y) do |s|
      s.x = 4
      s.y = 7
      s.name = "Home"
    end

The default constraint just checks the `id` of the record.

Where to put seed files
-----------------------

By default, seed files are looked for in the following locations:

* `#{Rails.root}/db/fixtures` and `#{Rails.root}/db/fixtures/#{Rails.env}` in a Rails app
* `./db/fixtures` when loaded without Rails

You can change these defaults by modifying the `SeedFu.fixture_paths` array.

Seed files can be named whatever you like, and are loaded in alphabetical order.

Terser syntax
-------------

When loading lots of records, the above block-based syntax can be quite verbose. You can use the following instead:

    User.seed(:id,
      { :id => 1, :login => "jon",   :email => "jon@example.com",   :name => "Jon"   },
      { :id => 2, :login => "emily", :email => "emily@example.com", :name => "Emily" }
    )

Rake task
---------

Seed files can be run automatically using `rake db:seed_fu`. There are two options which you can pass:

* `rake db:seed_fu FIXTURE_PATH=path/to/fixtures` -- Where to find the fixtures
* `rake db:seed_fu FILTER=users,articles` -- Only run seed files with a filename matching the `FILTER`

You can also do a similar thing in your code by calling `SeedFu.seed(fixture_paths, filter)`.

Disable output
--------------

To disable output from Seed Fu, set `SeedFu.quiet = true`.

Handling large seed files
-------------------------

Seed files can be huge.  To handle large files (over a million rows), try these tricks:

* Gzip your fixtures.  Seed Fu will read .rb.gz files happily.  `gzip -9` gives the   best compression, and with Seed Fu's repetitive syntax, a 160M file can shrink to 16M.
* Add lines reading `# BREAK EVAL` in your big fixtures, and Seed Fu will avoid loading the whole file into memory.  If you use `SeedFu::Writer`, these breaks are built into your generated fixtures.
* Load a single fixture at a time with the `FILTER` environment variable
* If you don't need Seed Fu's ability to update seed with new data, then you may find that [activerecord-import](https://github.com/zdennis/activerecord-import) is faster

Generating seed files
---------------------

If you need to programmatically generate seed files, for example to convert a CSV file into a seed file, then you can use [`SeedFu::Writer`](lib/seed-fu/writer.rb).

Capistrano deployment
---------------------

SeedFu has included Capistrano [deploy script](lib/seed-fu/capistrano.rb), you just need require that
in `config/deploy.rb`:

```ruby
require 'seed-fu/capistrano'

# Trigger the task after update_code
after 'deploy:update_code', 'db:seed_fu'
```

If you use Capistrano3, you should require another file.

```ruby
require 'seed-fu/capistrano3'

# Trigger the task before publishing
before 'deploy:publishing', 'db:seed_fu'
```

Bugs / Feature requests
-----------------------

Please report them on [Github Issues](https://github.com/mbleigh/seed-fu/issues).

Contributors
------------

* [Michael Bleigh](http://www.mbleigh.com/) is the original author
* [Jon Leighton](http://jonathanleighton.com/) is the current maintainer
* Thanks to [Matthew Beale](https://github.com/mixonic) for his great work in adding the writer, making it faster and better.

Copyright © 2008-2010 Michael Bleigh, released under the MIT license
