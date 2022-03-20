# frozen_string_literal: true

class AddUser
  Result = Struct.new(:success, :error, keyword_init: true)
  UserData = Struct.new(:external_id, :username, :first_name, :last_name, keyword_init: true)
  GroupData = Struct.new(:external_id, :title, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  # @param user_data [AddUser::UserData]
  # @param group_data [AddUser::GroupData]
  # @return result [AddUser::Result]
  def call(user_data:, group_data:)
    user = find_or_create_user(user_data)
    group = find_or_create_group(group_data)
    @repo.link_user_group(user.id, group.id)
    Application.logger.info { "user @#{user.username} added to group #{group.title}" }

    if user.location_expired? || user.help_request_expired?
      result = ShowRequestInfo.new.call(user: user)
      return Result.new(success: false, error: "request location failed: #{result.error}") unless result.success
    end

    Result.new(success: true)
  end

  private

  # @param user_data [UserData]
  # @return [User]
  def find_or_create_user(user_data)
    exist_user = @repo.find_user_by_external_id(user_data.external_id)
    return exist_user unless exist_user.nil?

    @repo.create_user(
      external_id: user_data.external_id,
      username: user_data.username,
      first_name: user_data.first_name,
      last_name: user_data.last_name
    )
  end

  # @param group_data [GroupData]
  # @return [Group]
  def find_or_create_group(group_data)
    exist_group = @repo.find_group_by_external_id(group_data.external_id)
    return exist_group unless exist_group.nil?

    @repo.create_group(
      external_id: group_data.external_id,
      title: group_data.title
    )
  end
end
