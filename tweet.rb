require 'clockwork'
require 'twitter'
require 'dotenv'
require 'awesome_print'

tweets_file = File.read('tweets.txt')

def check?
  ARGV.first == '--check'
end

if check?
  tweets_file.lines.map(&:chomp).each do |tweet|
    next if tweet.length <= 140
    diff = tweet.length - 140
    puts "#{tweet}\n is too long by #{diff} characters!"
  end
  exit 0 # Stops Clockwork from running
else
  include Clockwork
  Dotenv.load

  TIME = 1.minute

  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
  end

  tweets = tweets_file.lines.map(&:chomp).compact
  last_status_id = nil

  puts "#{tweets.length} lines? No problem."
  i = 1
  handler do |_|
    if !tweets.empty?
      tweet = tweets.shift
      if tweet != ''
        puts "Tweeting line #{i}"
        response = if last_status_id.nil?
                     client.update(tweet)
                   else
                     client.update(tweet, in_reply_to_status_id: last_status_id)
                   end
        puts "Tweeted line #{i}"
        last_status_id = response.id
      end
      i += 1
    else
      puts '*** End this script--no more tweets ***'
    end
  end

  every(TIME, 'tweet')
end
