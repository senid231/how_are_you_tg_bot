# frozen_string_literal: true

require 'rufus-scheduler'

module TelegramApp
  class Scheduler
    Job = Struct.new(:type, :args, :block, keyword_init: true)

    class << self
      attr_accessor :_jobs

      def cron(cron_time, &block)
        job = Job.new(type: :cron, args: [cron_time], block: block)
        self._jobs.push(job)
      end

      def in(time, &block)
        job = Job.new(type: :at, args: [time], block: block)
        self._jobs.push(job)
      end


      def at(time, &block)
        job = Job.new(type: :at, args: [time], block: block)
        self._jobs.push(job)
      end

      def every(time, &block)
        job = Job.new(type: :every, args: [time], block: block)
        self._jobs.push(job)
      end

      private

      def inherited(subclass)
        super
        subclass._jobs = []
      end
    end

    def initialize(app)
      @app = app
      @scheduler = nil
      @started = false
    end

    def start
      return if @started

      @scheduler = Rufus::Scheduler.new
      register_jobs
      @started = true
    end

    def stop
      @scheduler&.shutdown
      @started = false
    end

    private

    def register_jobs
      self.class._jobs.each do |job|
        @scheduler.public_send(job.type, *job.args) { job.block.call(@app) }
      end
    end

    def send_message(options)
      @app.bot_api.send_message(options)
    end
  end
end
