# frozen_string_literal: true

class GenerateStat
  Result = Struct.new(:success, :error, :text, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  def call(group:)
    if group.nil?
      text = format_stat([], [])
    else
      text = generate_stat(group)
    end
    Result.new(success: true, text: text)
  end

  private

  def generate_stat(group)
    users = @repo.collect_users_by_group(group.id)
    location_list = []
    help_list = []
    users.each do |user|
      user_info = "#{user.first_name} #{user.last_name} @#{user.username}"
      if user.location_added_at
        location_info = "знаходиться у #{user.location.inspect} (#{emoji_for(user, :location)}#{user.location_added_at.strftime('%F')})"
      else
        location_info = "немає інформації"
      end
      location_list.push("#{user_info} - #{location_info}")
      unless user.help_request.nil?
        help_list.push("#{user_info} потребує допомоги: #{user.help_request} (#{emoji_for(user, :help_request)}#{user.help_request_added_at.strftime('%F')})")
      end
    end
    format_stat(location_list, help_list)
  end

  def format_stat(location_list, help_list)
    [
      "Користувачів - #{location_list.size}",
      location_list.join("\n"),
      help_list.join("\n")
    ].join("\n\n")
  end

  def emoji_for(user, type)
    if type == :location
      user.location_expired? ? '⚠ ' : ''
    elsif type == :help_request
      user.help_request_expired? ? '⚠ ' : ''
    else
      raise ArgumentError, "invalid type #{type.inspect}"
    end
  end
end
