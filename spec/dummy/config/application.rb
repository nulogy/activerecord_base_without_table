require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require "active_record/base_without_table"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # These are the settings that PackManager uses.
    config.time_zone = "Eastern Time (US & Canada)"
    config.active_record.time_zone_aware_types = [:datetime]
  end
end
