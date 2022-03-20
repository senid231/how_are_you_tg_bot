# frozen_string_literal: true

class User < TelegramApp::Entity
  attribute :id
  attribute :external_id
  attribute :username
  attribute :first_name
  attribute :last_name
  attribute :location
  attribute :help_request
  attribute :wait_location, default: false
  attribute :wait_help_request, default: false
  attribute :location_added_at, type: :time
  attribute :help_request_added_at, type: :time
  attribute :created_at, type: :time

  EXPIRE_SECONDS = 60 #* 60 * 24 # 24 hours

  def location_expired?
    location_added_at.nil? || location_added_at.to_i < info_expired_at
  end

  def help_request_expired?
    help_request_added_at.nil? || help_request_added_at.to_i < info_expired_at
  end

  def info_expired_at
    Time.now.to_i - EXPIRE_SECONDS
  end
end
