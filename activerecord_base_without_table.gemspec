$:.push File.expand_path("../lib", __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activerecord_base_without_table"
  s.version     = "0.3.0"
  s.authors     = ["Ryan De Villa"]
  s.email       = ["ryand@nulogy.com"]
  s.homepage    = "https://nulogy.com"
  s.summary     = "Test harness for BaseWithoutTable migration to Rails 5"
  s.description = "Test harness for BaseWithoutTable migration to Rails 5"
  s.license     = "MIT"

  s.metadata = {
    "homepage_uri" => "https://github.com/nulogy/activerecord_base_without_table",
    "changelog_uri" => "https://github.com/nulogy/activerecord_base_without_table/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/nulogy/activerecord_base_without_table",
    "bug_tracker_uri" => "https://github.com/nulogy/activerecord_base_without_table/issues"
  }

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 5.2.3"
  s.add_dependency "sprockets", "3.7.2"
  s.add_dependency  "sprockets-rails", "3.2.1"

  s.add_development_dependency "pg", "~> 1.1"
  s.add_development_dependency "rspec", "~> 3.8"
  s.add_development_dependency "rspec-rails", "~> 3.8"
  s.add_development_dependency "byebug", "~> 11.0"
end
