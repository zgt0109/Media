require 'spec_helper'

describe Payment::VipUserpayController do

  describe "GET 'callback'" do
    it "returns http success" do
      get 'callback'
      response.should be_success
    end
  end

  describe "GET 'notify'" do
    it "returns http success" do
      get 'notify'
      response.should be_success
    end
  end

end
