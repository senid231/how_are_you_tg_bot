# frozen_string_literal: true

class GenerateStat
  Result = Struct.new(:success, :error, :text, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  def call(group:)
    return Result.new(success: true, text: 'Users (0)') if group.nil?

    text = generate_stat(group)
    Result.new(success: true, text: text)
  end

  private

  def generate_stat(group)
    users = @repo.collect_users_by_group(group.id)
    users_info = users.map do |user|
      "@#{user.username} - last location #{user.location.inspect} at #{user.location_added_at}"
    end
    "Users (#{users.size}):\n#{users_info.join("\n")}"
  end
end
