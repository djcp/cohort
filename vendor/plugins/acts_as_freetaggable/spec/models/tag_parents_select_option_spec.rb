require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "Tag Model" do
  context "#parent_select_options" do
    before(:all) do
      # A bit of setup, acts_as_category columns don't get filled in by fixtures
      Tag.all.each(&:delete)
      second = Tag.create(:title => "second", :description => "")
      first = Tag.create(:title => "first", :description => "")
      root = Tag.create(:title => "root", :description => "")
      root.children << first
      first.children << second
      [root,first,second].each(&:save)
      @parents = Tag.parent_select_options
    end
    it { Tag.should respond_to :parent_select_options }
    it "should have a no-parent root tag as the first option" do
      @parents.first.should == ["-- No Parent --", nil]
    end
    it "should have the 'root' tag in second" do
      tag = Tag.find_by_title('root')
      @parents.second.should == [tag.title, tag.id]
    end
    it "should have the 'first' tag in third" do
      tag = Tag.find_by_title('first')
      @parents.third.should == [' - ' + tag.title, tag.id]
    end
    it "should have the 'second' tag in fourth" do
      tag = Tag.find_by_title('second')
      @parents.fourth.should == [' - - ' + tag.title, tag.id]
    end
  end
end