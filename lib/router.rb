# frozen_string_literal: true

class Router < TelegramApp::Router
  command :help, action: 'HelpAction'
  command :start, action: 'StartAction'
  command :stop, action: 'StopAction'
  command :startgroup, type: 'group', action: 'StartGroupAction'
  command :stat, type: 'group', action: 'StatAction'
  command :my_groups, type: 'private', action: 'MyGroupsAction'
  command :menu, type: 'private', action: 'ShowRequestInfoAction'

  message /.+/, type: 'private', action: 'ProvideMessageAction'

  chat_event :current_bot_kicked, action: 'StopAction'
  chat_event :current_bot_left_group, action: 'StopAction'

  callback_query 'request_location', type: 'private', action: 'RequestLocationAction'
  callback_query 'request_location_same', type: 'private', action: 'ProvideLocationSameAction'
  callback_query 'request_help', type: 'private', action: 'RequestHelpAction'
  callback_query 'request_no_help', type: 'private', action: 'ProvideNoHelpAction'

  fallback do |message, app|
    Application.logger&.debug { "invalid message received:\n#{Utils::Format.pretty_format_message(message)}" }
    HelpAction.call(message: message, app: app)
  end
end
