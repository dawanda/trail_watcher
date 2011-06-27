require 'spec_helper'

describe Array do
  describe :index_of_elements_in_order do
    it "finds" do
      [1,2,3].index_of_elements_in_order([2,3]).should == 1
    end

    it "does not find" do
      [1,2].index_of_elements_in_order([2,3]).should == nil
    end

    it "find first" do
      [1,2,4,2,3].index_of_elements_in_order([2,3]).should == 3
    end
  end
end
