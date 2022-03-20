# frozen_string_literal: true

module TelegramApp
  class Router

    # Interface for route matcher.
    class Matcher
      # @param message [Telegram::Bot::Types::Base]
      # @param bot_info [TelegramApp::BotInfo]
      # @return [Boolean]
      def match?(message, bot_info)
        false
      end
    end

    # Route matcher for command.
    # Matches command like `/start` or `/start@<bot_name>`.
    class CommandMatcher < Matcher

      # @param command [Symbol,String]
      # @param type [String,Symbol,nil] chat type, any if nil passed, default nil.
      def initialize(command, type:)
        @command = command
        @type = type
      end

      def match?(message, bot_info)
        return false unless message.is_a?(Telegram::Bot::Types::Message)
        return false if !@type.nil? && message.chat.type != @type.to_s

        if message.chat.type == 'group' && message.text.split(' ').first == "/#{@command}@#{bot_info.username}"
          return true
        end

        message.text.split(' ').first == "/#{@command}"
      end
    end

    # Route matcher for text message.
    # Matches by regexp or exact text.
    class MessageMatcher < Matcher
      # @param text [String,Regexp]
      # @param type [String,Symbol,nil] chat type, any if nil passed, default nil.
      def initialize(text, type:)
        @text = text
        @type = type
      end

      def match?(message, bot_info)
        return false unless message.is_a?(Telegram::Bot::Types::Message)
        return false if !@type.nil? && message.chat.type != @type.to_s

        if @text.is_a?(Regexp)
          @text.match?(message.text)
        else
          @text == message.text
        end
      end
    end

    class ChatEventMatcher < Matcher
      def initialize(event_name, type: nil)
        @event_name = event_name
        @type = type
      end

      def match?(message, bot_info)
        return false unless message.is_a?(Telegram::Bot::Types::ChatMemberUpdated)

        ChatEventDetector.call(message: message, event_name: @event_name, bot_info: bot_info)
      end
    end

    class CallbackQueryMatcher < Matcher
      def initialize(data, type: nil)
        @data = data
        @type = type
      end

      def match?(message, bot_info)
        return false unless message.is_a?(Telegram::Bot::Types::CallbackQuery)
        return false if !@type.nil? && message.message.chat.type != @type.to_s

        if @data.is_a?(Regexp)
          @data.match?(message.data)
        else
          @data == message.data
        end
      end
    end

    class << self
      attr_accessor :_routes, :_fallback

      # @param matcher [TelegramApp::Router::Matcher]
      # @param action [#call,nil] used instead of block if passed.
      # @yield if action is nil.
      # @yieldparam message [Telegram::Bot::Types::Base]
      def route(matcher, action: nil, &block)
        raise ArgumentError, 'action or block must be passed' if action.nil? && !block_given?
        raise ArgumentError, "action and block can't both be passed" if !action.nil? && block_given?

        if action.is_a?(String)
          action_name = action
          action = proc { |message, app| Kernel.const_get(action_name).call(message: message, app: app) }
        end
        _routes.push(matcher: matcher, action: action || block)
      end

      # Routes command to action or proc.
      # @param command_name [Symbol,String]
      # @param type [String,Symbol,nil] chat type, any if nil passed, default nil.
      # @example
      #   command :start, action: StartAction
      #   command :startgroup, type: :group do |message|
      #     StartGroupAction.call(message)
      #   end
      #
      def command(command_name, type: nil, action: nil, &block)
        matcher = CommandMatcher.new(command_name, type: type)
        route(matcher, action: action, &block)
      end

      # Routes message to action or proc.
      # @param text [String,Regexp]
      # @param type [String,Symbol,nil] chat type, any if nil passed, default nil.
      def message(text, type: nil, action: nil, &block)
        matcher = MessageMatcher.new(text, type: type)
        route(matcher, action: action, &block)
      end

      def callback_query(data, type: nil, action: nil, &block)
        matcher = CallbackQueryMatcher.new(data, type: type)
        route(matcher, action: action, &block)
      end

      def chat_event(event_name, type: nil, action: nil, &block)
        matcher = ChatEventMatcher.new(event_name, type: type)
        route(matcher, action: action, &block)
      end

      def fallback(&block)
        self._fallback = block
      end

      private

      def inherited(subclass)
        super
        subclass._routes = []
      end
    end

    def initialize(app)
      @app = app
    end

    def call(message)
      if empty_message?(message)
        handle_empty_message(message)
        return
      end

      action = find_route(message)
      action ||= self.class._fallback
      action.call(message, @app) unless action.nil?
    end

    private

    # @param message [Telegram::Bot::Types::Base]
    # @return [#call,nil]
    def find_route(message)
      self.class._routes.each do |matcher:, action:|
        return action if matcher.match?(message, @app.bot_info)
      end
      nil
    end

    # @param message [Telegram::Bot::Types::Base]
    # @return [Boolean]
    def empty_message?(message)
      message.is_a?(Telegram::Bot::Types::Message) && message.text.to_s.empty?
    end

    # @param message [Telegram::Bot::Types::Message]
    def handle_empty_message(message)
      # Telegram sends message with empty text along with Telegram::Bot::Types::ChatMemberUpdated.
      # Since we handle it in ChatMemberUpdatedHandler, we just ignore such messages here.
    end
  end
end
