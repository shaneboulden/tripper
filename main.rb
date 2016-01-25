require 'sinatra'
require 'twitter'
require 'chartkick'
require 'sinatra/flash'

enable :sessions

get '/' do
  @title = 'Search'
  erb :home
end

post '/profile' do

  @client = Twitter::REST::Client.new do |config|
    # Use Heroku environment variables to authenticate to the Twitter API
    config.consumer_key = ENV['key']
    config.consumer_secret = ENV['secret']
  end

  puts 'Tripper::Search/'+params[:content]
  puts 'Tripper::User-agent/'+request.user_agent

  begin
    #create the user and show the profile page
    @user = @client.user(params[:content])

    # if the search is successful, print a message
    puts 'Tripper::User exists'

    # create instance variables for the chartkick charts
    @tweetsource ||= Hash.new(0)
    @retweet_total = 0
    @favourite_total = 0
    @num_tweets = 0
    @tweetday ||= {"Sunday" => 0, "Monday" => 0, "Tuesday" => 0,
                "Wednesday" => 0, "Thursday" => 0, "Friday" => 0,
                "Saturday" => 0}
    @followtz ||= Hash.new(0)
    sourcedays = Hash.new {|h,k| h[k] = []}
    @tweetline = Hash.new(0)

    #note that, by detault the user_timeline method returns the 20 most recent T
    #weets posted by the specified user
    @timeline = @client.user_timeline(@user.screen_name, :count => 200)
    @timeline.each do |t|
      @num_tweets += 1
      @retweet_total += t.retweet_count
      @favourite_total += t.favorite_count
      date = Date.parse(t.created_at.to_s[0..9])
      @tweetday[date.strftime('%A')] += 1

      # use a regular expression to get the text enclosed by
      # >< in the twitter source, then remove the first and last chars
      src = />(.*)</.match(t.source)[0][1..-2]
      @tweetsource[src] += 1
      sourcedays[src] << date.strftime('%Y-%m-%d')
      @tweetline[date] += 1
    end

    #format the sourcedays data
    @sourceplots = Hash.new {|h,k| h[k] = Hash.new(0)}
    sourcedays.each do |source, data|
      data.each do |date|
        @sourceplots[source][date] += 1
      end
    end

    erb :profile

    rescue Twitter::Error::NotFound => e
      puts 'Tripper::NotFound/'+e.message
      flash[:error] = e.message
      redirect '/'
    rescue Twitter::Error::Forbidden => e
      puts 'Tripper::Forbidden/'+e.message
      flash[:error] = e.message
      redirect '/'
    rescue Twitter::Error::Unauthorized => e
      puts 'Tripper::Unauthorized/'+e.message
      flash[:error] = 'Account protected (not authorized).'
      redirect '/'
  end
end
