# frozen_string_literal: true

module TelegramApp
  class Listener
    class << self
      attr_accessor :_handlers, :_fallback

      # @param message_class [Class<Telegram::Bot::Types::Base>]
      # @yieldparam message [Telegram::Bot::Types::Base]
      def handle(message_class, &block)
        _handlers[message_class] = block
      end

      def fallback(&block)
        self._fallback = block
      end

      private

      def inherited(subclass)
        super
        subclass._handlers = {}
      end
    end

    def call(message)
      self.class._handlers.each do |message_class, handler|
        if message.is_a?(message_class)
          instance_exec(message, &handler)
          return
        end
      end

      instance_exec(message, &self.class._fallback) unless self.class._fallback.nil?
    end
  end
end
