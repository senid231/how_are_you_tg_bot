# frozen_string_literal: true

class ProvideLocation
  Result = Struct.new(:success, :error, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  def call(user:, location:)
    @repo.update_user(user.id, wait_location: false, location: location, location_added_at: Time.now)
    # Application.logger.info { "user @#{user.username} provides location: #{location}" }
    Result.new(success: true)
  end
end
