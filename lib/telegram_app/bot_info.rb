# frozen_string_literal: true

module TelegramApp
  class BotInfo < Entity
    attribute :id
    attribute :is_bot
    attribute :first_name
    attribute :username
    attribute :can_join_groups
    attribute :can_read_all_group_messages
    attribute :supports_inline_queries
  end
end
