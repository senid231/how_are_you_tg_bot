# frozen_string_literal: true

require 'bundler/setup'
require_relative './utils'
require_relative './telegram_app'

class Application < TelegramApp::Application
  self.root = File.expand_path('..', __dir__)
  self.listener = 'Listener'
  self.scheduler = 'Scheduler'

  initializer do
    require_relative './initializer'
  end

  def self.usage
    <<-TEXT
Bot helps to track #{config.team_name} team members location.

Available commands:
/add_me - Add me to the ask-list for current group (only in groups)
/remove_me - Remove me from the ask-list of current group (in groups), or from all groups (in private)
/stat - See ask-list for current group (only in groups)
/my_groups - See which groups has me in ask-list
    TEXT
  end
end
