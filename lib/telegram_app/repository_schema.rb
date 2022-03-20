# frozen_string_literal: true

module TelegramApp
  class RepositorySchema
    class << self
      attr_accessor :repository_class
      attr_reader :_schema

      def schema(&block)
        @_schema = block
      end

      def call
        new.call
      end
    end

    def call
      repo_class = self.class.repository_class
      schema = self.class._schema
      repo_class.connection.instance_exec(&schema)
    end
  end
end
