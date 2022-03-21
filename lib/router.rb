# frozen_string_literal: true

class Router < TelegramApp::Router
  command :help, action: 'HelpAction'
  command :start, action: 'StartAction'
  command :stop, action: 'StopAction'
  command :startgroup, types: ['group', 'supergroup'], action: 'StartGroupAction'
  command :stat, types: ['group', 'supergroup'], action: 'StatAction'
  command :my_groups, types: ['private'], action: 'MyGroupsAction'
  command :menu, types: ['private'], action: 'ShowRequestInfoAction'

  message /.+/, types: ['private'], action: 'ProvideMessageAction'

  chat_event :current_bot_kicked, action: 'StopAction'
  chat_event :current_bot_left_group, action: 'StopAction'

  callback_query 'request_location', types: ['private'], action: 'RequestLocationAction'
  callback_query 'request_location_same', types: ['private'], action: 'ProvideLocationSameAction'
  callback_query 'request_help', types: ['private'], action: 'RequestHelpAction'
  callback_query 'request_no_help', types: ['private'], action: 'ProvideNoHelpAction'

  fallback do |message, app|
    Application.logger&.debug { "invalid message received:\n#{Utils::Format.pretty_format_message(message)}" }
    HelpAction.call(message: message, app: app)
  end
end
