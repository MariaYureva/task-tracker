Rails.application.configure do
  config.cache_classes = false
  config.action_view.cache_template_loading = true
  config.eager_load = ENV["CI"].present?
  config.consider_all_requests_local = true
  config.hosts.clear
  config.active_support.deprecation = :stderr
  config.active_support.disallowed_deprecation = :raise
  config.active_support.disallowed_deprecation_warnings = []
  config.action_dispatch.show_exceptions = :rescuable
  config.action_controller.allow_forgery_protection = false
  config.active_record.migration_error = :page_load
  config.action_controller.raise_on_missing_callback_actions = true
end