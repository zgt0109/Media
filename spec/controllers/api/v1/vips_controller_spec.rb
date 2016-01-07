require 'spec_helper'

describe Api::V1::VipsController do
  # it "should be true"
  context "POST 'pay' with invalid params" do
    it "returns http success" do
      post :pay
      response.should be_success
      json = JSON(response.body)
      json['errcode'].should_not == 0
      json.should include('errmsg')
      puts json
    end
  end
  
  context "POST 'pay' with valid params" do
    it "should return errcode: 0" do
      post :pay
      JSON(response.body)['errcode'].should == 0
    end
  end
end
