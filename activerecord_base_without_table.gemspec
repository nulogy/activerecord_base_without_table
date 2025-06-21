$LOAD_PATH.push File.expand_path("lib", __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "activerecord_base_without_table"
  spec.version     = "0.12.0"
  spec.authors     = ["Ryan De Villa", "Alistair McKinnell"]
  spec.email       = ["ryand@nulogy.com", "alistairm@nulogy.com"]
  spec.homepage    = "https://nulogy.com"
  spec.summary     = "Implements a variation on ActiveRecord::Base that is not backed by a table"
  spec.license     = "MIT"

  spec.metadata = {
    "homepage_uri" => "https://github.com/nulogy/activerecord_base_without_table",
    "changelog_uri" => "https://github.com/nulogy/activerecord_base_without_table/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/nulogy/activerecord_base_without_table",
    "bug_tracker_uri" => "https://github.com/nulogy/activerecord_base_without_table/issues",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  spec.required_ruby_version = ">= 3.3"

  spec.add_dependency "rails", ">= 7.1", "< 8.0"
end
