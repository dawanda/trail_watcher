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
  end
end
