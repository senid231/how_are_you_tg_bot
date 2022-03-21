# frozen_string_literal: true

module TelegramApp
  class ChatEventDetector
    class << self
      attr_accessor :_events

      # @param event_name [Symbol,String]
      # @param match [Proc]
      # @yieldparam message [Telegram::Bot::Types::ChatMemberUpdated]
      # @yieldreturn [Boolean]
      def register_event(event_name, match:)
        event_name = event_name.to_sym
        raise ArgumentError, "event #{event_name} already registered" if _events.key?(event_name)
        raise ArgumentError, 'block must be passed' if match.nil?

        _events[event_name.to_sym] = match
      end

      def call(message:, event_name:, bot_info:)
        new.call(message: message, event_name: event_name, bot_info: bot_info)
      end
    end

    self._events = {}

    register_event :current_bot_kicked, match: ->(message:, bot_info:) do
      old = message.old_chat_member
      new = message.new_chat_member
      return false if old.user.id != bot_info.id || new.user.id != bot_info.id

      old.status == 'member' && new.status == 'kicked'
    end

    register_event :current_bot_left_group, match: ->(message:, bot_info:) do
      old = message.old_chat_member
      new = message.new_chat_member
      return false if old.user.id != bot_info.id || new.user.id != bot_info.id

      ['group', 'supergroup'].include?(message.chat.type) && old.status == 'member' && new.status == 'left'
    end

    def call(message:, event_name:, bot_info:)
      block = self.class._events[event_name]
      raise ArgumentError, "invalid event #{event_name}" if block.nil?
      block.call(message: message, bot_info: bot_info)
    end
  end
end
