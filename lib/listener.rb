# frozen_string_literal: true

require_relative './message_handler'

class Listener < TelegramApp::Listener
  handle Telegram::Bot::Types::Message do |message|
    MessageHandler.new(Application.bot_info.username).call(message)
  end

  handle Telegram::Bot::Types::ChatMemberUpdated do |message|
    ChatMemberUpdatedHandler.new.call(message)
  end

  fallback do |message|
    Application.logger.warn { "unrecognized message received:\n#{Utils::Format.pretty_format_message(message)}" }
  end
end
