# frozen_string_literal: true

module Utils
  module Format
    module_function

    # @param message [Telegram::Bot::Types::Base]
    def pretty_format_message(message, prefix: '', prefix_step: ' ', prefix_step_count: 2)
      attribute_names = message.class.attribute_set.to_a.map(&:name)
      new_prefix = prefix + prefix_step * prefix_step_count
      lines = ["<#{message.class}>:"]
      attribute_names.each do |attribute_name|
        value = message.public_send(attribute_name)
        if value.is_a?(Telegram::Bot::Types::Base) || value.is_a?(Telegram::Bot::Types::Chat)
          formatted_value = pretty_format_message(value, prefix: new_prefix)
        else
          formatted_value = value.inspect
        end
        lines.push "#{new_prefix}#{attribute_name}=#{formatted_value}"
      end
      lines.join("\n")
    end

    def pretty_hash_message(message, replace_keys = {})
      result = {}
      attribute_names = message.class.attribute_set.to_a.map(&:name)
      attribute_names.each do |attribute_name|
        attribute_name = attribute_name.to_sym
        value = message.public_send(attribute_name)
        if value.is_a?(Telegram::Bot::Types::Base) || value.is_a?(Telegram::Bot::Types::Chat)
          value = pretty_hash_message(value)
        end
        key = replace_keys.fetch(attribute_name, attribute_name)
        result[key] = value
      end
      result
    end
  end
end
