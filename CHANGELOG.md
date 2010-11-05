Version 2.0.1
-------------

Bug fixes:

* Update the primary key sequence in PostgreSQL tables after seeding data. This ensures that id conflicts do not occur when records are subsequently added to the table.

* Raise ActiveRecord::RecordNotSaved if any of the saves fail (but they won't fail due to validation since saves are done without validation, so this guards against callbacks failing etc.)

Version 2.0.0
-------------

Features:

* Depends only on Active Record, not the whole of Rails

* The `Model.seed_many` syntax is now supported by `Model.seed`, and `Model.seed_many` is deprecated

* `Model.seed` supports adding multiple records without an explicit array argument. I.e. the following are equivalent:

      Model.seed([
        { :name => "Jon" },
        { :name => "Emily" }
      ])

      Model.seed(
        { :name => "Jon" },
        { :name => "Emily }
      )

* A side-effect of the above is another option for single seeds:

      Model.seed(:name => "Jon")

* The `SEED` option to `rake db:seed_fu` is deprecated, and replaced by `FILTER` which works the same way.

* Added `SeedFu.quiet` boolean option, set to `true` if you don't want any output from Seed Fu.

* Added `SeedFu.fixture_paths`. Set to an array of paths to look for seed files in. Defaults to `["db/fixtures"]` in general, or `["#{Rails.root}/db/fixtures", "#{Rails.root}/db/fixtures/#{Rails.env}"]` when Seed Fu is installed as a Rails plugin.

* Added `SeedFu.seed` method which is basically a method equivalent of running `rake db:seed_fu` (the rake task now just basically called `SeedFu.seed`)

* Simplified and changed the `SeedFu::Writer` API, see docs for details

Bug fixes:

* Fix Rails 3 deprecation warnings and make seed-fu fully compatible with being installed as a gem
