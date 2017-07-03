require 'clockwork'
require 'twitter'
require 'dotenv'

include Clockwork
Dotenv.load

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
else
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
    config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
  end

  tweets = tweets_file.lines

  handler do |_|
    unless tweets.empty?
      tweet = tweets.shift
      client.update(tweet)
    end
  end

  every(3.minutes, 'tweet')
end
