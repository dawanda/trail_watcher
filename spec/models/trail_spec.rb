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
  end
end
