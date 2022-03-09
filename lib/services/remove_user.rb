# frozen_string_literal: true

class RemoveUser
  Result = Struct.new(:success, :error, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  def call(user:, groups: nil)
    groups ||= @repo.collect_groups_by_user(user.id)

    groups.each do |group|
      remove_user_from_group(user, group)
      remove_empty_group(group)
    end

    remove_empty_user(user)
    Result.new(success: true)
  end

  private

  def remove_user_from_group(user, group)
    @repo.delete_link_user_group(user.id, group.id)
  end

  def remove_empty_group(group)
    if @repo.collect_users_by_group(group.id).empty?
      @repo.delete_group(group.id)
    end
  end

  def remove_empty_user(user)
    if @repo.collect_groups_by_user(user.id).empty?
      @repo.delete_user(user.id)
    end
  end
end
