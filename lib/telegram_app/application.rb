# frozen_string_literal: true

require 'logger'
require 'telegram/bot'

module TelegramApp
  class Application
    include Singleton

    class ThreadSafeProxy
      def initialize(target)
        @target = target
        @mutex = Mutex.new
      end

      def respond_to_missing?(symbol, include_all = false)
        if @target.respond_to?(symbol, include_all)
          true
        else
          super
        end
      end

      private

      def method_missing(symbol, *args, &block)
        if @target.respond_to?(symbol)
          @mutex.synchronize { @target.public_send(symbol, *args, &block) }
        else
          super
        end
      end
    end

    class << self
      attr_reader :_configure

      def configure(&block)
        @_configure = block
      end

      def method_missing(name, *args, &block)
        if instance.respond_to?(name)
          instance.public_send(name)
        else
          super
        end
      end

      def respond_to_missing?(name, include_all = false)
        if instance.respond_to?(name, include_all)
          true
        else
          super
        end
      end
    end

    attr_accessor :config,
                  :router,
                  :scheduler,
                  :logger,
                  :root_path,
                  :bot_client_options

    attr_reader :bot,
                :bot_api,
                :bot_info,
                :root

    def initialize
      @bot = nil
      @bot_info = nil
      @setup_finished = false
      @running = false
      @interrupted = false
      @around_receive = nil
      @bot_api_mutex = Mutex.new
    end

    def setup
      return if @setup_finished

      self.class._configure.call(self)
      connect_bot
      @setup_finished = true
    end

    # Starts telegram bot server.
    def run
      raise ArgumentError, "#{self.class.name} already running" if @running

      setup
      logger.info('Starting bot')
      catch_interruption { @interrupted = true }
      @running = true
      scheduler&.start
      run_once until @interrupted
    ensure
      scheduler&.stop
      @running = false
    end

    def root=(value)
      @root = Pathname.new(value.to_s)
    end

    def run_once
      bot.fetch_updates do |message|
        within_message_context(message) do
          router.call(message)
        end
      end
    end

    def interrupt!
      @interrupted = true
    end

    def around_receive(&block)
      @around_receive = block
    end

    private

    def within_message_context(message)
      return yield if @around_receive.nil?

      @around_receive.call(message) { yield }
    end

    def connect_bot
      opts = { logger: logger, timeout: 5 }.merge(bot_client_options || {})
      @bot = Telegram::Bot::Client.new(config.token, opts)
      @bot_api = ThreadSafeProxy.new(bot.api)
      logger&.info { "Connecting to #{bot.api.url} ..." }
      @bot_info = get_bot_info
      logger&.info { 'Connected.' }
      print_bot_info
    end

    def print_bot_info
      info_line = bot_info.to_h.map { |k, v| "#{k}=#{v.inspect}" }.join(', ')
      logger&.info { "Bot info: #{info_line}" }
    end

    def get_bot_info
      response = bot_api.get_me
      raise ArgumentError, "Failed to retrieve bot info: #{response}" unless response['ok']

      BotInfo.new response['result']
    end

    def catch_interruption(&block)
      Signal.trap('INT') do
        logger&.info { 'INT signal caught. Interrupting...' }
        block.call
      end
    end
  end
end
