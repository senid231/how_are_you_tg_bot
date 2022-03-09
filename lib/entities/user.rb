# frozen_string_literal: true

class User < TelegramApp::Entity
  attribute :id
  attribute :external_id
  attribute :username
  attribute :location
  attribute :wait_location, default: false
  attribute :location_added_at, type: :time
  attribute :created_at, type: :time

  LOCATION_EXPIRE_SECONDS = 60 * 60 * 24 # 24 hours

  def location_expired?
    location_added_at.nil? || location_added_at.to_i < (Time.now.to_i - LOCATION_EXPIRE_SECONDS)
  end
end
