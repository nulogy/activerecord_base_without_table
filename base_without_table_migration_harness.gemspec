$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "base_without_table_migration_harness/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "base_without_table_migration_harness"
  s.version     = BaseWithoutTableMigrationHarness::VERSION
  s.authors     = ["Ryan De Villa"]
  s.email       = ["ryand@nulogy.com"]
  s.homepage    = "https://nulogy.com"
  s.summary     = "Test harness for BaseWithoutTable migration to Rails 5"
  s.description = "Test harness for BaseWithoutTable migration to Rails 5"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.10"

  s.add_development_dependency "pg", "0.18.4"
  s.add_development_dependency "rspec", "3.5.0"
  s.add_development_dependency "rspec-rails", "3.5.2"
  s.add_development_dependency "byebug", "9.0.6"
end
