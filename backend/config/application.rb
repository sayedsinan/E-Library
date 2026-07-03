require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module EbookLibrary
  class Application < Rails::Application
    config.load_defaults 7.1

    # API-only app
    config.api_only = true

    # Autoload validators
    config.autoload_paths << Rails.root.join("app/validators")
  end
end
