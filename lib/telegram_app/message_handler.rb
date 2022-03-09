# frozen_string_literal: true

module TelegramApp
  class MessageHandler
    Matcher = Struct.new(:text, :type, :caller, keyword_init: true) do
      def match?(message, _)
        return false if !type.nil? && type.to_s != message.chat.type

        if text.is_a?(Regexp)
          text.match?(message.text)
        else
          text == message.text
        end
      end
    end

    CommandMatcher = Struct.new(:command, :type, :caller, keyword_init: true) do
      def match?(message, bot_username)
        return false if !type.nil? && type.to_s != message.chat.type
        return true if message.text == "/#{command}"
        return true if message.chat.type == 'group' && message.text == "/#{command}@#{bot_username}"

        false
      end
    end

    class << self
      attr_accessor :_matchers, :_fallback

      private

      def inherited(subclass)
        super
        subclass._matchers = _matchers&.dup || []
      end

      def match(text, type: nil, &block)
        matcher = Matcher.new(text: text, type: type, caller: block)
        _matchers.push(matcher)
      end

      def command(command, type: nil, &block)
        matcher = CommandMatcher.new(command: command, type: type, caller: block)
        _matchers.push(matcher)
      end

      def fallback(&block)
        self._fallback = block
      end
    end

    def initialize(bot_username)
      @bot_username = bot_username
    end

    def call(message)
      matcher = find_matcher(message)
      caller = matcher&.caller || self.class._fallback
      instance_exec(message, &caller) unless caller.nil?
    end

    private

    def find_matcher(message)
      self.class._matchers.detect do |matcher|
        matcher.match?(message, @bot_username)
      end
    end
  end
end
