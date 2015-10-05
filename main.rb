require 'sinatra'
require 'twitter'
require 'chartkick'
require 'sinatra/flash'
#require 'googlecharts'
#require 'gchart'

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

      @title='Search'
      
      # Log the search (also appears in papertrail)
      puts 'Tripper::Search/'+params[:content]

      begin
        #create the user and show the profile page
        @user = @client.user(params[:content])     
        
        # if the search is successful, print a message
        puts 'Tripper::User exists'

        # create the objects for the chartkick charts
     
        @tweetsource ||= Hash.new(0)
        @retweet_total = 0
        @num_tweets = 0
        @tweetday ||= {"Sunday" => 0, "Monday" => 0, "Tuesday" => 0,
                    "Wednesday" => 0, "Thursday" => 0, "Friday" => 0,
                    "Saturday" => 0}
        @followtz ||= Hash.new(0)
        @sourcedays = Hash.new(0)
        @tweetline = Hash.new(0)

        #note that the user_timeline method returns the 20 most recent Tweets 
        #posted by the specified user - rate limiting?
        timeline = @client.user_timeline(@user.screen_name, :count => 200)
        timeline.each do |t|
          @num_tweets += 1
          @retweet_total += t.retweet_count
          date = Date.parse(t.created_at.to_s[0..9])
          @tweetday[date.strftime('%A')] += 1
      
          # use a regular expression to get the text enclosed by 
          # >< in the twitter source, then remove the first and last chars
          src = />(.*)</.match(t.source)
          @tweetsource[src[0][1..-2]] += 1

          @tweetline[date] += 1

          #push the date and src onto a hash
          #@sourcedays[src[0][1..-2]] += [date,1]
          #puts "date: #{date}, src: #{src[0][1..-2]}"
          # note data needs to be of the form [
          #   {name: "series A", data: series_a},
          #   {name: "series B", data: series_b}
          # ]
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
      end
end    
