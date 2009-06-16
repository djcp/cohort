require File.join(File.dirname(__FILE__), "/../spec_helper")

describe Tag do
  VALID_ATTRIBUTES = { :title => "title", :description => "description" }
  context "tree" do
    after(:each) do
      Tag.all.each(&:destroy)
    end
    subject { Tag }
    specify { should respond_to :roots }

    it "should tidy up orphaned objects" do
      construct_tree
      # Note #delete does _NOT_ trigger children deletion
      parent = Tag.create! VALID_ATTRIBUTES
      child_id = parent.children.create!(VALID_ATTRIBUTES).id
      grand_child_id = parent.children[0].children.create!(VALID_ATTRIBUTES).id
      parent.destroy
      lambda { Tag.find child_id }.should raise_error
      lambda { Tag.find grand_child_id }.should raise_error
    end
    it "should be capable of mass child reassignment" do
      construct_tree
      root2_count = @root2.children.count
      root1_count = @root.children.count
      assert @root.children << @root2.children #don't put me in a lambda
      @root.should be_valid
      @root.save; @root.reload
      @root.children.count.should be root1_count + root2_count
    end
  end

  context "tree node" do
    before(:each) do
      @tag = Tag.create(VALID_ATTRIBUTES)
    end
    subject { @tag }
    it { should respond_to :children }
    it { should respond_to :descendants }
    it { should respond_to :parent }
    it { should respond_to :parent= }
    it { should respond_to :ancestors }
    it "cannot be its own parent" do
      @tag.parent = @tag
      @tag.should_not be_valid
    end
    it "can change parent" do
      @tag2 = Tag.create
      lambda { @tag.parent = @tag2 }.should_not raise_error
      @tag.parent.should == @tag2
    end
    it "can leave its parent and become root" do
      @tag2 = Tag.create(VALID_ATTRIBUTES)
      @tag.parent = @tag2
      @tag.parent = nil
      @tag.save
      @tag.parent.should be nil
      Tag.roots.should include @tag
    end
    it "will be valid when #new'd and assigned own parent (but not yet saved)" do
      # Bug or feature? Can't assign parent properly unless id created
      @tag = Tag.new(VALID_ATTRIBUTES)
      @tag.parent = @tag
      @tag.should be_valid
    end
    it "should not allow destruction if unremovable" do
      @tag.removable = false
      @tag.destroy.should be false
    end

    it { should respond_to :depth }
    it "should know its depth" do
      @root = Tag.create(:title => "root", :description => "Root")
      @child = Tag.create(:title => "child", :description => "Root")
      @root.children << @child
      [@root,@child].each(&:save).each(&:reload)
      @root.depth.should be 0
      @child.depth.should be 1
    end
  end
end

