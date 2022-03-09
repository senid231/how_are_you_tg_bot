# frozen_string_literal: true

module TelegramApp
  class Entity
    class << self
      attr_accessor :_attributes

      def attribute(name, type: nil, default: nil)
        _attributes[name.to_s] = { type: type, default: default }
        define_method(name) { read_attribute(name) }
      end

      private

      def inherited(subclass)
        super
        subclass._attributes = self._attributes&.dup || {}
      end
    end

    def initialize(attributes = {})
      @attributes = {}
      assign_default_attributes
      assign_attributes(attributes)
    end

    def to_h
      @attributes.dup
    end

    private

    def assign_default_attributes
      self.class._attributes.each do |name, opts|
        write_attribute name, opts[:default]
      end
    end

    def assign_attributes(attributes)
      return if attributes.nil?

      attributes.each do |name, value|
        write_attribute(name, value)
      end
    end

    def write_attribute(name, value)
      name = name.to_s
      type = self.class._attributes.fetch(name)[:type]
      @attributes[name] = coerce_value(value, type)
    end

    def read_attribute(name)
      @attributes.fetch(name.to_s)
    end

    def coerce_value(value, type)
      return value if type.nil? || value.nil?

      send("coerce_#{type}!", value)
    end

    def coerce_time!(value)
      return value if value.is_a?(Time)

      Time.parse(value)
    end
  end
end
