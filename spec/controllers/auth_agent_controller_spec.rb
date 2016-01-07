require 'spec_helper'

describe AuthAgentController do

  describe "GET 'wx_oauth'" do
    it "returns http success" do
      get 'wx_oauth'
      response.should be_success
    end
  end

  describe "GET 'wx_oauth_callback'" do
    it "returns http success" do
      get 'wx_oauth_callback'
      response.should be_success
    end
  end

end
