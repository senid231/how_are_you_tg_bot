# frozen_string_literal: true

require 'logger'
require 'forwardable'
require 'telegram/bot'

module TelegramApp
  class Application
    extend Forwardable

    BotInfo = Struct.new(
      :id,
      :is_bot,
      :first_name,
      :username,
      :can_join_groups,
      :can_read_all_group_messages,
      :supports_inline_queries,
      keyword_init: true
    )

    class << self
      attr_accessor :listener, :scheduler, :config
      attr_reader :root, :instance, :_initializer

      def root=(path)
        path = Pathname.new(path) if path && !path.is_a?(Pathname)
        @root = path
      end

      # Starts telegram bot server.
      def run
        raise ArgumentError, "#{name} already running" unless instance.nil?

        @instance = new
        instance.run(
          config.token,
          listener: listener,
          scheduler: scheduler
        )
      end

      def initializer(&block)
        @_initializer = block
      end

      def method_missing(name, *args, &block)
        if !instance.nil? && instance.respond_to?(name)
          instance.public_send(name)
        else
          super
        end
      end

      def respond_to_missing?(name, include_all = false)
        if !instance.nil? && instance.respond_to?(name, include_all)
          true
        else
          super
        end
      end
    end

    attr_reader :bot, :logger, :bot_info
    def_instance_delegators :'self.class', :config

    # Starts telegram bot server.
    # @param token [String] bot api token
    # @param listener [#call] will receive all messages from users to the bot.
    # @param scheduler [#call, nil] will be called on each iteration, for scheduled jobs, etc.
    def run(token, listener:, scheduler: nil)
      prepare_bot(token, listener: listener, scheduler: scheduler)
      logger.info('Starting bot')
      running = true
      Signal.trap('INT') { running = false }
      run_once while running

      exit
    end

    def prepare_bot(token, listener:, scheduler: nil)
      @logger = Logger.new($stdout)
      $stdout.sync = true
      @bot = Telegram::Bot::Client.new(token, logger: @logger, timeout: 5)
      @bot_info = get_bot_info
      print_bot_info
      self.class._initializer&.call
      @listener = Kernel.const_get(listener).new
      @scheduler = Kernel.const_get(scheduler).new unless scheduler.nil?
    end

    def run_once
      @bot.fetch_updates { |message| @listener.call(message) }
      @scheduler&.call
      # rescue Faraday::ConnectionFailed => e
      # logger.error { "#{e.class}: #{e.message}\n#{e.backtrace&.join("\n")}" }
    end

    def print_bot_info
      info_line = bot_info.to_h.map { |k, v| "#{k}=#{v.inspect}" }.join(', ')
      logger.info { "Bot info: #{info_line}" }
      logger.info { "Team name: #{config.team_name}" }
    end

    def get_bot_info
      response = @bot.api.get_me
      return unless response['ok']

      BotInfo.new response['result']
    end
  end
end
