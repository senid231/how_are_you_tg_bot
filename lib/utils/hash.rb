# frozen_string_literal: true

module Utils
  module Hash
    module_function

    def transform(data)
      result = {}
      data.each do |key, value|
        new_key, new_value = yield [key, value]
        result[new_key] = new_value
      end
      result
    end

    def transform_keys(data)
      transform(data) do |key, value|
        new_key = yield key
        [new_key, value]
      end
    end

    def stringify_keys(data)
      transform_keys(data, &:to_s)
    end

    def symbolize_keys(data)
      transform_keys(data, &:to_sym)
    end

    def deep_symbolize_keys(data)
      transform(data) do |key, value|
        new_key = key.to_sym
        if value.is_a?(Hash)
          new_value = deep_symbolize_keys(value)
        elsif value.is_a?(Array)
          new_value = value.map do |val|
            val.is_a?(Hash) ? deep_symbolize_keys(val) : val
          end
        else
          new_value = value
        end
        [new_key, new_value]
      end
    end
  end
end
