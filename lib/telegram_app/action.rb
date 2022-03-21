# frozen_string_literal: true

require 'forwardable'

module TelegramApp
  class Action
    extend Forwardable

    class << self
      attr_accessor :_before_callbacks, :_handle_send_exception

      def call(message:, app:)
        new(message: message, app: app).perform_action
      end

      def before_action(meth = nil, &block)
        block ||= proc { send(meth) }
        self._before_callbacks.push(block)
      end

      def handle_send_exception(meth = nil, &block)
        block ||= proc { send(meth) }
        self._handle_send_exception = block
      end

      private

      def inherited(subclass)
        super
        subclass._before_callbacks = []
        subclass._handle_send_exception = nil
      end
    end

    attr_reader :app, :message
    def_instance_delegators :app, :logger, :bot_api, :bot_info

    def initialize(message:, app:)
      @app = app
      @message = message
    end

    def perform_action
      halt_reason = catch(:halt) do
        run_before_callbacks
        call
        nil
      end
      logger&.warn { "#{self.class} halt reason: #{halt_reason}" } unless halt_reason.nil?
    end

    private

    def chat
      return @chat if defined?(@chat)

      @chat = populate_chat
    end

    def from
      return @from if defined?(@from)

      @from = populate_from
    end

    def populate_chat
      return message.chat if message.respond_to?(:chat)
      return message.message.chat if message.is_a?(Telegram::Bot::Types::CallbackQuery)

      nil
    end

    def populate_from
      message.from
    end

    def send_message(options)
      bot_api.send_message(options)
    rescue Telegram::Bot::Exceptions::ResponseError => e
      handle_send_exception(e)
    end

    def handle_send_exception(exception)
      block = self.class._handle_send_exception
      return instance_exec(exception, &block) unless block.nil?

      logger&.error { "<#{exception.class}> #{exception.message}\n#{exception.backtrace&.join("\n")}" }
    end

    def halt_message(options)
      send_message(options)
      halt
    end

    def halt(reason = nil)
      throw(:halt, reason)
    end

    def run_before_callbacks
      self.class._before_callbacks.each do |block|
        instance_exec(&block)
      end
    end
  end
end
