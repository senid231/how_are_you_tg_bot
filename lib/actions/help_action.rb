# frozen_string_literal: true

class HelpAction < ApplicationAction
  def call
    send_message(chat_id: chat.id, text: TextHelper.help)
  end
end
