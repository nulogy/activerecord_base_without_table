# ActiveRecord::BaseWithoutTable

Get the power of ActiveRecord models, including validation, without having a table in the database.

This is a fork of the original project by Jonathan Viney, Peter Abrahamsen, and Peter Suschlik,
with modifications to make it compatible with more recent versions of Rails.

## Create the dummy database

```
cd spec/dummy
rails db:create
```

## Running the specs

```
bundle exec appraisal install
bundle exec appraisal rake
```
