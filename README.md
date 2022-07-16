# SQLite adapter for Rocket ETL
This gem provides useful controls to operate Rocket with SQLite databases.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'rocket_etl-sqlite'
```

And then execute:

```bash
$ bundle install
```

Require `rocket/sqlite` in the `config/app.rb` file:

```ruby
require "rocket/sqlite"
```

## Usage

You can now use the adapter in your YAML configuration:

```yml
adapters:
  some_sqlite_database:
    adapter: "sqlite"
    database: "example.db"
```

You can pass any option recognized by sequel.
See [the Sequel SQLite options list](https://sequel.jeremyevans.net/rdoc-adapters/classes/Sequel/SQLite/Database.html#method-i-connect) for further details.

The configured adapter can now be used in Rocket jobs e.g.:

```ruby
source :some_sqlite_database, :paginated, page_size: 42
def select_some_stuff(db, offset, limit)
  db[:items].offset(offset).limit(limit)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitLab at https://gitlab.com/[USERNAME]/rocket_etl-sqlite. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://gitlab.com/[USERNAME]/rocket_etl-sqlite/blob/master/CODE_OF_CONDUCT.md).

## Code of Conduct

Everyone interacting in the RocketEtl::SQLite project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://gitlab.com/[USERNAME]/rocket_etl-sqlite/blob/master/CODE_OF_CONDUCT.md).
