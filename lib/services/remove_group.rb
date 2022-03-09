# frozen_string_literal: true

class RemoveGroup
  Result = Struct.new(:success, :error, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  def call(group:)
    users ||= @repo.collect_users_by_group(group.id)

    users.each do |user|
      @repo.delete_link_user_group(user.id, group.id)
    end

    @repo.delete_group(group.id)
    Result.new(success: true)
  end
end
