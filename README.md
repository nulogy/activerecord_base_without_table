# ActiveRecord::BaseWithoutTable

Get the power of ActiveRecord models, including validation, without having a table in the database.

This is a fork of the original project by Jonathan Viney, Peter Abrahamsen, and Peter Suschlik,
with modifications to make it compatible with more recent versions of Rails.

## Create the dummy database

```
cd spec/dummy
BUNDLE_GEMFILE=../../Gemfile rails db:create
BUNDLE_GEMFILE=../../Gemfile rails db:migrate
```

## Running the specs

Note: update the version of bundler as appropriate.

```
bundle _2.7.2_ exec appraisal install
bundle exec appraisal rake
```
