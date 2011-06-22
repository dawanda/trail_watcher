require 'spec_helper'

describe TrailsController do
  describe "GET 'track'" do
    it "is successful" do
      get 'track', :path => '/xxx'
      response.should be_success
    end

    it "is builds a trail" do
      Trail.delete_all
      lambda{
        get 'track', :path => '/xxx'
      }.should change{Trail.count}.by(+1)
    end

    it "renders an image" do
      get 'track', :path => '/xxx'
      response.content_type.should == 'image/gif'
    end
  end
end
