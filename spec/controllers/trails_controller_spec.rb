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

    it "sets trail cookie" do
      get 'track', :path => '/xxx'
      cookies[:trail_watcher_trail_id].size.should == 24
    end

    it "reuses trail cookie" do
      id = Trail.track!(:path => '/xxx')
      request.cookies[:trail_watcher_trail_id] = id
      lambda{
        get 'track', :path => '/xxx'
      }.should_not change{Trail.count}
    end

    it "can set attributes" do
      get 'track', :path => '/xxx', 'data-account_state' => 'registered'
      Trail.find_by_id(response.cookies['trail_watcher_trail_id']).account_state.should == 'registered'
    end
  end
end
