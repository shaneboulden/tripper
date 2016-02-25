# basic tests for the t-ripper app
RSpec.describe Sinatra::Application do
  context "without Twitter API authentication" do
    it "returns the home page successfully" do
      get '/'
        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Search by Twitter handle')
        expect(last_response.body).not_to include('flash error')
    end

    context "open Twitter account" do
      it "flashes an error" do
        get '/stephenathome'
          expect(last_response.status).to eq(302)
          follow_redirect!
          expect(last_response.status).to eq(200)
          expect(last_response.body).to include('<span class="flash error">Unable to verify your credentials</span>')
      end
    end
  end

  context "with Twitter API authentication" do
    before(:all) do
      Dotenv.load('.env')
    end

    context "open Twitter account" do
      it "gets a Twitter profile successfully" do
        get '/stephenathome'
          expect(last_response.status).to eq(200)
          expect(last_response.body).to include('Screen name')
          expect(last_response.body).not_to include('flash error')
      end
    end

    context "locked Twitter account" do
      it "flashes an error"  do
        # FIXME find a locked profile to use
      end
    end

    context "suspended Twitter account" do
      it "flashes an error" do
        get '/isis_news'
          follow_redirect!
          expect(last_response.body).to include('<span class="flash error">User has been suspended.</span>')
      end
    end
  end
end

