#!/usr/bin/env ruby

require 'logan'
require 'yaml'
require 'rest-client'
require 'json'
require 'htmlentities'

# Helper class since logan gem wants rails dates
class ExtTime
  attr_accessor :time

  def initialize(time)
    @time = time
  end

  def to_formatted_s(format)
    if format == :iso8601
      @time.iso8601(3)
    end
  end

  def to_s
    to_formatted_s(:iso8601)
  end
end

def slack_notify(message, channel, attachment)
  payload = {
    channel: channel,
    username: @settings['SLACK_BOT_NAME'],
    text: message,
  }

  bot_icon = @settings['SLACK_BOT_ICON']
  if bot_icon and /^[a-z0-9_\-]+$/i.match(bot_icon)
    payload[:icon_emoji] = bot_icon
  elsif bot_icon
    payload[:icon_url] = bot_icon
  end

  url = @settings['SLACK_WEBHOOK_URL']
  payload[:attachments] = attachment if attachment
  RestClient.post(url, payload.to_json, content_type: :json)
  puts "message sent to #{channel}"
end

@settings = YAML::load_file(File.expand_path('config/settings.yml'))

begin
  # last run file name
  last_run_filename = File.expand_path('last_run_date.txt')
  save_last_run_date = false

  # set the default last run date
  if File.exist?(last_run_filename)
    last_run_date = Time.parse(File.read(last_run_filename))
  else
    last_run_date = Time.now - 2 * 24 * 60 * 60
    save_last_run_date = true
  end
  since = ExtTime.new(last_run_date)
  puts "getting global events since #{since}"

  # initiate the basecamp service
  service = Logan::Client.new(
    @settings['BASECAMP_ID'],
    {
      username: @settings['BASECAMP_USERNAME'],
      password: @settings['BASECAMP_PASSWORD'],
    },
    'ruby-slackcamp'
  )
  
  # get the events and reverse them to send the older events first
  events = service.events(since)
  events = events.reverse if events

  for event in events
    raw_event = JSON.parse(event.json_raw)
    message = "#{raw_event['creator']['name']} #{event.action.gsub!(/<[^>]+>/i, '')} <#{raw_event['html_url']}|#{raw_event['target']}>"
    attachment = nil
    if event.excerpt
      excerpt = HTMLEntities.new.decode(event.excerpt)
      attachment = {
        fallback: excerpt,
        fields: {
          title: raw_event['creator']['name'],
          text: excerpt,
          short: false,
        },
      }
    end

    # see if a specific slack channel is set for notifications
    channel = @settings['SLACK_DEFAULT_CHANNEL']
    channel = @settings['SLACK_CHANNELS'][raw_event['bucket']['name']] if @settings['SLACK_CHANNELS'][raw_event['bucket']['name']]

    # send the slack message
    slack_notify(message, channel, attachment) if channel

    # update the last run date based on the latest basecamp event retrieved
    last_run_date = event.created_at;
    save_last_run_date = true;
  end

  # persist the last run date
  if save_last_run_date
    f = File.open(last_run_filename, 'w')
    f.print(last_run_date)
    f.close
    puts "setting last run date to #{last_run_date}"
  end
rescue Exception => e
  puts e.message
end

puts 'DONE!'
