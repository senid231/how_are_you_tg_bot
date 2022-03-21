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
      # @param types [Array<String>,nil] chat types, any if nil passed.
      def initialize(command, types:)
        @command = command
        @types = types
      end

      def match?(message, bot_info)
        return false unless message.is_a?(Telegram::Bot::Types::Message)
        return false if !@types.nil? && @types.include?(message.chat.type)

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
      # @param types [Array<String>,nil] chat types, any if nil passed.
      def initialize(text, types:)
        @text = text
        @types = types
      end

      def match?(message, bot_info)
        return false unless message.is_a?(Telegram::Bot::Types::Message)
        return false if !@types.nil? && @types.include?(message.chat.type)

        if @text.is_a?(Regexp)
          @text.match?(message.text)
        else
          @text == message.text
        end
      end
    end

    class ChatEventMatcher < Matcher
      # @param types [Array<String>,nil] chat types, any if nil passed.
      def initialize(event_name, types: nil)
        @event_name = event_name
        @types = types
      end

      def match?(message, bot_info)
        return false unless message.is_a?(Telegram::Bot::Types::ChatMemberUpdated)
        return false if !@types.nil? && @types.include?(message.chat.type)

        ChatEventDetector.call(message: message, event_name: @event_name, bot_info: bot_info)
      end
    end

    class CallbackQueryMatcher < Matcher
      # @param types [Array<String>,nil] chat types, any if nil passed.
      def initialize(data, types: nil)
        @data = data
        @types = types
      end

      def match?(message, bot_info)
        return false unless message.is_a?(Telegram::Bot::Types::CallbackQuery)
        return false if !@types.nil? && @types.include?(message.message.chat.type)

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
      # @param types [Array<String>,nil] chat type, any if nil passed, default nil.
      # @example
      #   command :start, action: StartAction
      #   command :startgroup, type: :group do |message|
      #     StartGroupAction.call(message)
      #   end
      #
      def command(command_name, types: nil, action: nil, &block)
        matcher = CommandMatcher.new(command_name, types: types)
        route(matcher, action: action, &block)
      end

      # Routes message to action or proc.
      # @param text [String,Regexp]
      # @param types [Array<String>,nil] chat type, any if nil passed, default nil.
      def message(text, types: nil, action: nil, &block)
        matcher = MessageMatcher.new(text, types: types)
        route(matcher, action: action, &block)
      end

      def callback_query(data, types: nil, action: nil, &block)
        matcher = CallbackQueryMatcher.new(data, types: types)
        route(matcher, action: action, &block)
      end

      def chat_event(event_name, types: nil, action: nil, &block)
        matcher = ChatEventMatcher.new(event_name, types: types)
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
