require 'time'
require 'redis'
require 'json'
require 'google/cloud/firestore'

module Cache
  REDIS_TTL = 60 * 60 # 1時間
  FIRE_STORE_TTL = 60 * 60 # 1時間
  KEY_PREFIX = 'utsushie-'

  def self.set(key)
    set_redis(key) if redis_enable?
    set_firestore(key) if firestore_enable?
  end

  def self.exists?(key)
    redis_exists?(key) if redis_enable?
    firestore_exists?(key) if firestore_enable?
  end

  private
  def self.redis_enable?
    ENV['REDIS_URL'] && !ENV['REDIS_URL'].empty?
  end

  def self.redis_exists?(key)
    redis = Redis.new(:url => ENV['REDIS_URL'])
    check_old_cache(redis)
    cache = redis.get(Cache::KEY_PREFIX + key)

    return !cache.nil?
  end

  def self.set_redis(key)
    redis = Redis.new(:url => ENV['REDIS_URL'])
    json = {
      created_at: Time.now
    }.to_json

    redis.set(Cache::KEY_PREFIX + key, json, ex: Cache::REDIS_TTL)
  end

  def self.check_old_cache(redis)
    # ttl導入前のkeyが残り続けることを避ける
    keys = redis.keys(Cache::KEY_PREFIX + "*")
    keys.each do |key|
      if redis.ttl(key) == -1
        redis.expire(key, Cache::REDIS_TTL)
      end
    end
  end

  def self.firestore_enable?
    ENV['FIRESTORE_COLLECTION'] && !ENV['FIRESTORE_COLLECTION'].empty?
  end

  def self.set_firestore(key)
    hash = {
      created_at: Time.now,
      expires_at: Time.now + Cache::FIRE_STORE_TTL
    }
    firestore = Google::Cloud::Firestore.new
    doc = firestore.doc(firestore_key(key))
    doc.set(hash)
  end

  def self.firestore_exists?(key)
    firestore = Google::Cloud::Firestore.new
    ref = firestore.doc(firestore_key(key))
    return !ref.get.fields.nil?
  end

  def self.firestore_key(key)
    ENV['FIRESTORE_COLLECTION'] + "/" + key
  end

end
