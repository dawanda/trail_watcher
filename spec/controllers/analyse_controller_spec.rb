require 'spec_helper'

describe AnalyseController do
  describe :index do
    it "renders without input" do
      get :index
      response.should render_template(:index)
      assigns[:data].should == nil
    end

    it "renders with input" do
      Trail.create!(:path => ';/xxx;/yyy;')
      get :index, :paths => ['/xxx'], :compare => {'0' => 'all'}
      response.should render_template(:index)
      assigns[:data].should == [['/xxx',1]]
    end

    it "compares tags" do
      Trail.create!(:path => ';/xxx;/yyy;', :tags => ['register'])
      Trail.create!(:path => ';/xxx;/yyy;', :tags => ['register'])
      Trail.create!(:path => ';/xxx;/yyy;', :tags => ['login'])
      Trail.create!(:path => ';/xxx;/yyy;')
      get :index, :paths => ['/xxx'], :compare => {'0' => 'all', '1' => 'register'}
      response.should render_template(:index)
      assigns[:data].should == [["/xxx", 4, 2]]
    end
  end

  describe :org do
    it "renders without input" do
      get :org
      response.should render_template(:org)
      assigns[:data].should == []
    end

    it "renders with input" do
      Trail.create!(:path => ';/xxx;/yyy;')
      get :org, :paths => ['/xxx', '/yyy']
      response.should render_template(:org)
      assigns[:selected_paths].should == ['/xxx','/yyy']
      assigns[:data].should == [["END", 100.0]]
    end

    it "reverse selection" do
      Trail.create!(:path => ';/foo;/xxx;/yyy;', :tags => ['register'])
      Trail.create!(:path => ';/xxx;/yyy;', :tags => ['register'])
      Trail.create!(:path => ';/xxx;/yyy;', :tags => ['register'])
      Trail.create!(:path => ';/xxx;/yyy;', :tags => ['login'])
      Trail.create!(:path => ';/xxx;/yyy;')
      get :org, :paths => ['/xxx', '/yyy'], :show => 'start'
      assigns[:selected_paths].should == ['/yyy','/xxx']
      assigns[:data].should == [["/yyy", 80.0], ["/foo", 20.0]]
    end
  end
end
