require 'time'
require 'redis'

module Cache
  REDIS_URL = ENV['REDIS_URL'] || "redis://127.0.0.1:6379/0"
  KEY_PREFIX = 'utsushie-'

  def self.set(key)
    redis = Redis.new(:url => Cache::REDIS_URL)
    clear_old_cache(redis)
    json = {
      created_at: Time.now
    }.to_json

    redis.set(Cache::KEY_PREFIX + key, json)
  end

  def self.exists?(key)
    redis = Redis.new(:url => Cache::REDIS_URL)
    clear_old_cache(redis)
    cache = redis.get(Cache::KEY_PREFIX + key)

    return !cache.nil?
  end

  private
  def self.clear_old_cache(redis)
    keys = redis.keys(Cache::KEY_PREFIX + "*")
    now = Time.now
    keys.each do |key|
      json = redis.get(key)
      cache = JSON.parse(json)
      created_at = Time.parse(cache['created_at'])
      diff = now - created_at

      # 1時間以上前のログを消す
      redis.del(key) if diff > (60 * 60)
    end
  end
end
