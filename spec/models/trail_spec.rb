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
      Trail.find_by_id(id).paths.should == ['yyy']
    end

    it "fails without path" do
      lambda{ Trail.track!(:path => nil) }.should raise_error
    end

    it "tracks referrer as visit" do
      id = Trail.track!(:path => 'yyy', :referrer => 'xxx')
      Trail.find_by_id(id).paths.should == ['xxx','yyy']
    end

    it "does not track referrer as visit for existing trails" do
      id = Trail.track!(:path => 'yyy')
      Trail.track!(:path => 'zzz', :referrer => 'xxx', :id => id)
      Trail.find_by_id(id).paths.should == ['yyy','zzz']
    end

    describe 'tags' do
      it "sets tags" do
        id = Trail.track!(:path => 'yyy', :tags => 'registered,facebook')
        Trail.find_by_id(id).tags.should == ['registered','facebook']
      end

      it "adds tags" do
        lambda{
          id = Trail.track!(:path => 'xxx', :tags => 'registered')
          id = Trail.track!(:path => 'yyy', :tags => 'facebook', :id => id)
          Trail.find_by_id(id).tags.should == ['registered','facebook']
        }.should change{Trail.count}.by(+1)
      end

      it "does not add duplicate tags" do
        lambda{
          id = Trail.track!(:path => 'xxx', :tags => 'registered')
          id = Trail.track!(:path => 'yyy', :tags => 'registered', :id => id)
          Trail.find_by_id(id).tags.should == ['registered']
        }.should change{Trail.count}.by(+1)
      end

      it "does not add tags from the same group" do
        id = Trail.track!(:path => 'xxx', :tags => 'register')
        id = Trail.track!(:path => 'yyy', :tags => 'login', :id => id)
        Trail.find_by_id(id).tags.should == ['register']
      end

      it "does not add tags from the same group in same request" do
        id = Trail.track!(:path => 'xxx', :tags => 'register,login')
        Trail.find_by_id(id).tags.should == ['register']
      end
    end
  end

  describe :unique_tag_groups do
    it "leaves non-unique alone" do
      Trail.unique_tag_groups(['a','b'], [['a','c'],['b','d']]).should == ['a','b']
    end

    it "leaves removes duplicates" do
      Trail.unique_tag_groups(['a','b','c'], [['a','b']]).should == ['a','c']
    end

    it "leaves removes duplicates in order" do
      Trail.unique_tag_groups(['b','a','c'], [['a','b']]).should == ['b','c']
    end
  end

  describe :tags do
    it "has sorted unique tags" do
      Trail.create!(:tags => ['b','a'])
      Trail.create!(:tags => ['b','c'])
      Trail.tags.should == ['a','b','c']
    end
  end

  describe :between_dates do
    before do
      Delorean.time_travel_to '2011-01-01 01:00:00' do
        Trail.create!
      end
      Delorean.time_travel_to '2011-01-03 01:00:00' do
        Trail.create!
      end
      Delorean.time_travel_to '2011-01-04 01:00:00' do
        Trail.create!(:path => '/xxx')
      end
      Delorean.time_travel_to '2011-01-05 01:00:00' do
        Trail.create!(:path => '/xxx')
      end
    end

    it "finds with from and to" do
      Trail.between_dates('2011-01-01', '2011-01-03').size.should == 2
      Trail.between_dates('2011-01-01', '2011-01-02').size.should == 1
      Trail.between_dates('2011-01-02', '2011-01-03').size.should == 1
    end

    it "finds with from or to and scope" do
      Trail.where(:path => '/xxx').between_dates('2011-01-01', '2011-01-04').size.should == 1
    end

    it "finds without from or to" do
      Trail.between_dates('', '').size.should == 4
    end

    it "finds without from or to and scope" do
      Trail.where(:path => '/xxx').between_dates('', '').size.should == 2
    end

    it "finds without from" do
      Trail.between_dates('', '2011-01-03').size.should == 2
    end

    it "finds without to" do
      Trail.between_dates('2011-01-03','').size.should == 3
    end
  end
end
