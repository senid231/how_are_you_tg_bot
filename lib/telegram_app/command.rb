# frozen_string_literal: true

module TelegramApp
  class Command
    def call(message)
      raise NotImplementedError
    end
  end
end
