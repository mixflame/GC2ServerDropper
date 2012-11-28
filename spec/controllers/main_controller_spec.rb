require 'spec_helper'

describe MainController do

  describe "GET 'welcome'" do
    it "returns http success" do
      get 'welcome'
      response.should be_success
    end
  end

  describe "GET 'check_server'" do
    it "returns http success" do
      get 'check_server', :host => 'globalchat2.net', :port => '9994'
      response.should be_success
    end
  end


  describe "GET 'drop_server'" do
    it "returns http success" do
      #binding.pry
      get 'drop_server', :host => 'localhost', :name => "ChucklesServer", :password => "hi", :private => "false", :scrollback => "true", :temporary => "0BV10U5P4SSW0RD"
      response.should be_success
    end
  end

end
