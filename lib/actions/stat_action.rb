# frozen_string_literal: true

class StatAction < ApplicationAction
  def call
    result = GenerateStat.new.call(group: group)
    unless result.success
      halt_message(chat_id: chat.id, text: "Error: failed to generate stat, #{result.error}")
    end

    send_message(chat_id: chat.id, text: result.text)
  end
end
