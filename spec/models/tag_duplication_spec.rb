require File.join(File.dirname(__FILE__), "/../spec_helper")

describe Tagging do
  it "should not create duplicate taggings" do
    t = Tag.create(:title => 'auto tag')
    c = Contact.new
    c.tags << t

    lambda { c.save }.should_not raise_error
  end
end
