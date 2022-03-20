# frozen_string_literal: true

class Configuration < TelegramApp::Configuration
  self.config_path = File.expand_path('./config.yml', __dir__)

  attr_config :database_url
  attr_config :sentry_dsn
  attr_config :sentry_env
  attr_config :sentry_tags
end
