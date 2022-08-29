require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'slack-notifier'
require 'open-uri'
require 'fileutils'

require_relative 'lib/cache'
require_relative 'lib/emoji'
require_relative 'lib/esa_emoji_client'

SLACK_WEBHOOK_URL = ENV["SLACK_WEBHOOK_URL"]
ESA_ACCESS_TOKEN = ENV['ESA_ACCESS_TOKEN']
ESA_TEAM_NAME = ENV['ESA_TEAM_NAME']
IMAGE_BUFFER_DIR = "images"
IGNORE_EMOJI_LIST = ENV['IGNORE_EMOJI_LIST'] || '' # e.g. "ignore_emoji1, ignore_emoji2, ignore_emoji3"

if ESA_ACCESS_TOKEN.nil? || ESA_TEAM_NAME.nil? || SLACK_WEBHOOK_URL.nil?
  puts "[ERROR]: Require ENV['ESA_ACCESS_TOKEN']." if ESA_ACCESS_TOKEN.nil?
  puts "[ERROR]: Require ENV['ESA_TEAM_NAME']." if ESA_TEAM_NAME.nil?
  puts "[ERROR]: Require ENV['SLACK_WEBHOOK_URL']." if SLACK_WEBHOOK_URL.nil?
  exit
end

class App < Sinatra::Base
  get '/' do
    return 'ok'
  end

  post '/' do
    json = request.body.read
    payload = JSON.parse(json)

    case payload['type']
    when 'url_verification'
      challenge = payload['challenge']
      return { challenge: challenge }.to_json
    when 'event_callback'
      event_id = payload['event_id']
      return if Cache.exists?(event_id)
      Cache.set(event_id)

      event = payload['event']
      case event['type']
      when 'emoji_changed'
        case event['subtype']
        when 'add'
          name = event['name']

          ignore_emojis = IGNORE_EMOJI_LIST.split(',').map(&:strip) || []
          return if ignore_emojis.include?(name)

          is_alias = event['value'].start_with?('alias:')

          if is_alias
            target_name = event["value"].gsub(/^alias:/, "")
            App.add_emoji_alias(name, target_name)
          else
            url = event['value']
            App.add_emoji(name, url)
          end
        when 'remove'
          names = event['names']
          names.each do |name|
            ignore_emojis = IGNORE_EMOJI_LIST.split(',').map(&:strip) || []
            next if ignore_emojis.include?(name)

            App.remove_emoji(name)
          end
        end
      end
    end
  end

  def self.add_emoji(name, url)
    emoji = Emoji.new(name, url)
    dry_run = ENV['SINATRA_ENV'] == 'test'

    path = "./#{IMAGE_BUFFER_DIR}/#{emoji.filename}"

    # EmojiをDLする
    unless dry_run
      # SlackからDLした絵文字画像を保存するフォルダを準備
      Dir.mkdir(IMAGE_BUFFER_DIR) if not Dir.exist?(IMAGE_BUFFER_DIR)

      URI.open(emoji.url) do |file|
        open(path, "w+b") do |out|
          out.write(file.read)
        end
      end
    end

    esa_emoji_client = EsaEmojiClient.new(ESA_ACCESS_TOKEN, ESA_TEAM_NAME, dry_run)
    message = esa_emoji_client.add(emoji, path)
    message ||= "esaに :#{emoji.name}: `#{emoji.name}` を追加しました。"

    post_to_slack(message)

    unless dry_run
      FileUtils.rm(path)
    end
  end

  def self.add_emoji_alias(name, target_name)
    dry_run = ENV['SINATRA_ENV'] == 'test'
    esa_emoji_client = EsaEmojiClient.new(ESA_ACCESS_TOKEN, ESA_TEAM_NAME, dry_run)
    message = esa_emoji_client.add_alias(name, target_name)
    message ||= "esaに :#{name}: `#{name}` を `#{target_name}` のエイリアスとして追加しました。"

    post_to_slack(message)
  end

  def self.remove_emoji(name)
    dry_run = ENV['SINATRA_ENV'] == 'test'
    esa_emoji_client = EsaEmojiClient.new(ESA_ACCESS_TOKEN, ESA_TEAM_NAME, dry_run)
    message = esa_emoji_client.remove(name)
    message ||= "esaから :#{name}: `#{name}` を削除しました。"

    post_to_slack(message)
  end

  def self.post_to_slack(message)
    dry_run = ENV['SINATRA_ENV'] == 'test'
    notifier = Slack::Notifier.new(SLACK_WEBHOOK_URL)

    options = {
      attachments: [
        {
          fallback: message,
          text:     message,
          color:    '#4A9994',
        },
      ],
    }

    notifier.ping(nil, options) unless dry_run
  end
end
