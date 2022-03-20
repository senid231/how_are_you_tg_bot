# frozen_string_literal: true

class StartGroupAction < ApplicationAction
  def call
    send_message(chat_id: chat.id, text: "Greeting @#{from.username} from #{chat.title.inspect} group")
  end
end
