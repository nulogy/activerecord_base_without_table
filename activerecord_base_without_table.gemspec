$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "activerecord_base_without_table"
  spec.version     = "0.4.0"
  spec.authors     = ["Ryan De Villa", "Alistair McKinnell"]
  spec.email       = ["ryand@nulogy.com", "alistairm@nulogy.com"]
  spec.homepage    = "https://nulogy.com"
  spec.summary     = "Test harness for BaseWithoutTable migration to Rails 5"
  spec.description = "Test harness for BaseWithoutTable migration to Rails 5"
  spec.license     = "MIT"

  spec.metadata = {
    "homepage_uri" => "https://github.com/nulogy/activerecord_base_without_table",
    "changelog_uri" => "https://github.com/nulogy/activerecord_base_without_table/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/nulogy/activerecord_base_without_table",
    "bug_tracker_uri" => "https://github.com/nulogy/activerecord_base_without_table/issues"
  }

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  spec.test_files = Dir["test/**/*"]

  spec.required_ruby_version = ">= 2.6"

  spec.add_runtime_dependency "rails", "5.2.4.2"

  spec.add_development_dependency "byebug", "~> 11.1"
  spec.add_development_dependency "pg", "~> 1.2"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "rspec-rails", "~> 3.9"
  spec.add_development_dependency "rubocop", "~> 0.82"
  spec.add_development_dependency "rubocop-rspec", "~> 1.39"
end
