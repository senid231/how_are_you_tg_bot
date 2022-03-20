# frozen_string_literal: true

class Repository < TelegramApp::Repository
  # @param external_id [String]
  # @return [User,nil]
  def find_user_by_external_id(external_id)
    attrs = connection[:users].where(external_id: external_id).first
    return if attrs.nil?

    User.new(attrs)
  end

  # @param external_id [String]
  # @return [Group,nil]
  def find_group_by_external_id(external_id)
    attrs = connection[:groups].where(external_id: external_id).first
    return if attrs.nil?

    Group.new(attrs)
  end

  # @param attrs [Hash]
  # @return [User]
  def create_user(attrs)
    attrs = Utils::Hash.symbolize_keys(attrs).merge(created_at: Time.now)
    create(:users, attrs)
    find_user_by_external_id attrs[:external_id]
  end

  # @param id [Integer]
  # @param attrs [Hash]
  # @return [User]
  def update_user(id, attrs)
    attrs = Utils::Hash.symbolize_keys(attrs)
    update(:users, id, attrs)
    User.new connection[:users].where(id: id).first
  end

  # @param attrs [Hash]
  # @return [Group]
  def create_group(attrs)
    attrs = Utils::Hash.symbolize_keys(attrs).merge(created_at: Time.now)
    create(:groups, attrs)
    find_group_by_external_id attrs[:external_id]
  end

  # @param user_id [Integer]
  # @param group_id [Integer]
  def link_user_group(user_id, group_id)
    return if connection[:users_groups].where(user_id: user_id, group_id: group_id).count > 0

    create(:users_groups, user_id: user_id, group_id: group_id, created_at: Time.now)
  end

  # @param group_id [Integer]
  # @return [Array<User>]
  def collect_users_by_group(group_id)
    user_ids = connection[:users_groups].where(group_id: group_id).select_map(:user_id)
    return [] if user_ids.empty?

    connection[:users].where(id: user_ids).map { |attrs| User.new(attrs) }
  end

  # @return [Array<User>]
  def collect_users
    connection[:users].all.map { |attrs| User.new(attrs) }
  end

  # @return [Array<Group>]
  def collect_groups
    connection[:groups].all.map { |attrs| Group.new(attrs) }
  end

  # @param user_id [Integer]
  def collect_groups_by_user(user_id)
    group_ids = connection[:users_groups].where(user_id: user_id).select_map(:group_id)
    return [] if group_ids.empty?

    connection[:groups].where(id: group_ids).map { |attrs| Group.new(attrs) }
  end

  # @param user_id [Integer]
  # @param group_id [Integer]
  def delete_link_user_group(user_id, group_id)
    connection[:users_groups].where(user_id: user_id, group_id: group_id).delete
  end

  # @param id [Integer]
  def delete_group(id)
    delete(:groups, id)
  end

  # @param id [Integer]
  def delete_user(id)
    delete(:users, id)
  end
end
