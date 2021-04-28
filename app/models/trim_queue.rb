# frozen_string_literal: true

class TrimQueue
  SET_KEY = 'users-pending-trim'

  def self.clear
    Redis.current.del SET_KEY
  end

  def self.push(user_id)
    Redis.current.sadd SET_KEY, user_id
  end

  def self.pop
    val = Redis.current.spop SET_KEY
    Integer(val) if val
  end
end
