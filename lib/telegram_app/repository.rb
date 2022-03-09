# frozen_string_literal: true

require 'forwardable'
require 'sequel'

module TelegramApp
  class Repository
    extend Forwardable

    Error = Class.new(StandardError)

    class << self
      attr_accessor :database_name
      attr_reader :_schema

      def schema(&block)
        @_schema = block
      end

      def connection
        @connection ||= build_connection
      end

      def build_connection
        Sequel.connect(database_name)
      end

      def check_schema
        return if _schema.nil?

        connection.instance_exec(&_schema)
      end
    end

    private

    def_instance_delegator :'self.class', :connection

    # @param table [String,Symbol]
    # @param id [Integer]
    def find(table, id)
      connection[table.to_sym].where(id: id).first
    end

    # @param table [String,Symbol]
    # @param attrs [Hash]
    def create(table, attrs)
      connection[table.to_sym].insert(attrs)
    end

    # @param table [String,Symbol]
    # @param id [Integer]
    # @param attrs [Hash]
    def update(table, id, attrs)
      connection[table.to_sym].where(id: id).update(attrs)
    end

    # @param table [String,Symbol]
    # @param id [Integer]
    def delete(table, id)
      connection[table.to_sym].where(id: id).delete
    end
  end
end
