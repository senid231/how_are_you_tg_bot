# frozen_string_literal: true

class Group < TelegramApp::Entity
  attribute :id
  attribute :external_id
  attribute :title
  attribute :created_at
end
