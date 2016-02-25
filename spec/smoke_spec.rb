# basic tests for the t-ripper app
RSpec.describe "t-ripper app" do
  it "returns the home page" do
   get '/'
     expect(last_response).to be_ok
  end
end
