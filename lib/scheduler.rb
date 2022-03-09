# frozen_string_literal: true

class Scheduler
  def call
    Repository.new.collect_users.each do |user|
      ask_location(user) if need_to_ask_location?(user)
    end
  end

  private

  def need_to_ask_location?(user)
    user.location_expired? && !user.wait_location
  end

  def ask_location(user)
    RequestLocation.new.call(user: user)
  end
end
