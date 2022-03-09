# frozen_string_literal: true

require_relative './telegram_app/configuration'

class Configuration < TelegramApp::Configuration
  self.config_path = Application.root.join('config/config.yml')

  attr_config :team_name
  attr_config :database
end
