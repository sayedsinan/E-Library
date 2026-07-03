Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.active_storage.service = :local
  config.action_dispatch.show_exceptions = :all
  config.active_support.deprecation = :log
  config.log_level = :debug
end
