# frozen_string_literal: true

class AddUser
  Result = Struct.new(:success, :error, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  def call(user_external_id:, username:, group_external_id:, group_title:)
    user = @repo.find_user_by_external_id(user_external_id) || @repo.create_user(external_id: user_external_id, username: username)
    group = @repo.find_group_by_external_id(group_external_id) || @repo.create_group(external_id: group_external_id, title: group_title)
    @repo.link_user_group(user.id, group.id)
    Application.logger.info { "user @#{user.username} added to group #{group.title}" }

    if user.location_expired?
      result = RequestLocation.new.call(user: user)
      return Result.new(success: false, error: "request location failed: #{result.error}") unless result.success
    end

    Result.new(success: true)
  end
end
