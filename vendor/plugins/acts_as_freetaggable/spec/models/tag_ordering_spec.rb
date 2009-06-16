require File.join(File.dirname(__FILE__), "/../spec_helper")

describe Tag do
  #Through all the stuff I did I found that ordering requires #reloads to truly work as expected. Without them orderings don't come through properly
  context "ordering" do
    before(:all) do
      @tags = construct_tree
    end
    it "should order roots by position" do
      root_positions = Tag.roots.map(&:position)
      lambda { root_positions.sort }.should_not change(root_positions, :first)
    end
    it "should order children by position" do
      children_positions = @root.children.map(&:position)
      lambda { children_positions.sort }.should_not change(children_positions, :first)
    end
    it "should order siblings by position" do
      @root.children.create # Add a third child to @root
      sibling_positions = @tag_two.siblings.map(&:position)
      lambda { sibling_positions.sort }.should_not change(sibling_positions, :first)
    end

    it "can reorder tags" do
      ids = @root.children.map(&:id)
      @root.children.first.move_down
      @root.reload
      @root.children.map(&:id).should_not be ids
      @root.children.second.move_up
      @root.reload
      # Check that each id is now the old id
      ids.each_with_index do |id, i|
        id.should be @root.children[i].id
      end
    end
    it "can reorder root tags" do
      ids = Tag.roots.map(&:id)
      tag_to_move = Tag.roots.second
      lambda {
        tag_to_move.move_up
      }.should change(tag_to_move, :position).from(2).to(1)
    end

    it "shouldn't move a tag with no siblings" do
      tag_to_move = @root2.children.first
      @root2.children.count.should be 1
      lambda { tag_to_move.move_up }.should_not change { tag_to_move.position }
    end

    it { @tag_one.should respond_to :move_up }
    context "#move_up" do
      it "should change position of non-top tag" do
        tag_to_move = @root.children.second
        lambda { tag_to_move.move_up }.should change(tag_to_move, :position).from(2).to(1)
      end
      it "should change position of tag above" do
        tag_to_move = @root.children.second
        displaced_tag = @root.children.first
        lambda { tag_to_move.move_up; displaced_tag.reload }.should change(displaced_tag, :position).from(1).to(2)
      end
      it "should not move the top tag" do
        tag_to_move = @root.children.first
        lambda { tag_to_move.move_up }.should_not change(tag_to_move, :position)
      end
    end

    it { @tag_one.should respond_to :move_down }
    context "#move_down" do
      it "should change position of non-bottom tag when moved down" do
        tag_to_move = @root.children.first
        lambda { tag_to_move.move_down }.should change(tag_to_move, :position)
      end
      it "should change position of displaced tag when non-bottom tag is moved down" do
        tag_to_move = @root.children.first
        displaced_tag = @root.children.second
        lambda { tag_to_move.move_down; displaced_tag.reload }.should change(displaced_tag, :position).from(2).to(1)
      end
      it "should not move the top tag" do
        tag_to_move = @root.children.last
        lambda { tag_to_move.move_down }.should_not change(tag_to_move, :position)
      end
    end

    it "should be maintained through a mass assignment" do
      # i.e. [a,b] << [c,d] == [c,d,a,b] with objects in same order
      root_kids = @root.children
      root2_kids = @root2.children
      expected_root_kids = root2_kids + root_kids
      @root.children << @root2.children

      [@root,@root2].each(&:save).each(&:reload)

      @root2.children.count.should be 0
      @root.children.each_with_index do |child,i|
        child.id.should be expected_root_kids[i].id
      end
      Tag.all.each(&:destroy)
      construct_tree
    end
  end
end
