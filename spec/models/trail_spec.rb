require 'spec_helper'

describe Trail do
  describe :track! do
    it "add a Trail if none exists" do
      lambda{
        Trail.track!(:path => 'yyy')
      }.should change{Trail.count}.by(+1)
    end

    it "does not add a trail if one exists" do
      lambda{
        id = Trail.track!(:path => 'yyy')
        Trail.track!(:id => id, :path => 'xxx')
      }.should change{Trail.count}.by(+1)
    end

    it "does not create a new trail if time has not expired" do
      lambda{
        id = Trail.track!(:path => 'yyy')
        Delorean.time_travel_to Trail::TIMEOUT.from_now-3 do
          Trail.track!(:id => id, :path => 'xxx')
        end
      }.should change{Trail.count}.by(+1)
    end

    it "creates a new trail if time has expired" do
      lambda{
        id = Trail.track!(:path => 'yyy')
        Delorean.time_travel_to Trail::TIMEOUT.from_now+1 do
          Trail.track!(:id => id, :path => 'xxx')
        end
      }.should change{Trail.count}.by(+2)
    end

    it "adds visits" do
      id = Trail.track!(:path => 'yyy')
      Trail.find_by_id(id).visits.count.should == 1
    end

    it "fails without path" do
      lambda{ Trail.track!(:path => nil) }.should raise_error
    end

    it "tracks referrer as visit" do
      id = Trail.track!(:path => 'yyy', :referrer => 'xxx')
      Trail.find_by_id(id).visits.map(&:path).should == ['xxx','yyy']
    end

    it "does not track referrer as visit for existing trails" do
      id = Trail.track!(:path => 'yyy')
      Trail.track!(:path => 'zzz', :referrer => 'xxx', :id => id)
      Trail.find_by_id(id).visits.map(&:path).should == ['yyy','zzz']
    end

    it "sets attributes" do
      id = Trail.track!(:path => 'yyy', 'data-account_state' => 'registered')
      Trail.find_by_id(id).account_state.should == 'registered'
    end

    it "updates attributes" do
      lambda{
        id = Trail.track!(:path => 'xxx')
        id = Trail.track!(:path => 'yyy', 'data-account_state' => 'registered', :id => id)
        Trail.find_by_id(id).account_state.should == 'registered'
      }.should change{Trail.count}.by(+1)
    end
  end
end
