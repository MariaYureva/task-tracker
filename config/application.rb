require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

module TaskTracker
  class Application < Rails::Application
    config.load_defaults 7.1

    config.api_only = true

    config.time_zone = "UTC"

    config.autoload_paths << Rails.root.join("app/services")

    config.generators do |g|
      g.test_framework :rspec, fixtures: false, view_specs: false,
                       helper_specs: false, routing_specs: false
      g.factory_bot dir: "spec/factories"
    end
  end
end