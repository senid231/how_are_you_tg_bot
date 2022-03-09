# frozen_string_literal: true

require 'yaml'
require 'erb'

module TelegramApp
  class Configuration
    class << self
      attr_accessor :config_path

      def load_config
        content = ERB.new(File.read(config_path)).result
        data = YAML.load(content)
        new(data)
      end

      # Defines config key
      # @param name [String,Symbol] config key
      def attr_config(name)
        name = name.to_s
        define_method(name) { @config[name] }
      end
    end

    attr_config :token

    def initialize(data)
      @config = {}
      assign_data(data)
    end

    private

    def assign_data(data)
      data.each do |name, value|
        @config[name.to_s] = value
      end
    end
  end
end
