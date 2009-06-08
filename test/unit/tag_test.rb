require 'test_helper'

class TagTest < ActiveSupport::TestCase
  context "Tags" do
    should_have_many :taggings
    should_have_many :contacts
    
    setup do
      @tag = get_a_tag
    end

    should "act as list" do
      assert_respond_to @tag, :move_higher
    end

    should "act as tree" do
      assert_respond_to @tag, :children
    end
    
    context "with contacts" do
      setup do
        @contact = get_a_contact
      end
      should "be able to have a contact" do
        assert @contact.tags.count == 0
        @contact.tags = [@tag]
        assert @contact.save
        assert @contact.tags.count == 1
      end

      should "be able to delete tag" do
        @contact.tags = [@tag]
        @contact.save
        assert @contact.tags.length == 1
        assert @tag.destroy
        @contact.reload
        assert @contact.tags.length == 0
      end

      should "can delete a contact with a tag" do
        @contact.tags = [@tag]
        @contact.save
        @contact.reload
        assert @contact.destroy
      end
    end
  end
  
  should "can reorder tags" do
    t = Tag.find 5
    assert t.position == 1
    assert t.move_lower
    t.reload
    assert t.position == 2
  end

  should "tag has children" do
    t = Tag.find 4
    assert t.children.length == 2
  end

  should "can reassign parent" do
    t = Tag.find 5
    tparent = Tag.find 1
    t.parent = tparent
    assert t.save
    t.reload
    tparent.reload
    assert tparent.children.find(t)
  end

  should "can orphan tag" do
    t = Tag.find 5
    t.parent = nil
    assert t.save
    t.reload
    assert t.parent == nil
  end

  should "can mass reassign children" do
    t = Tag.find 4
    children = t.children
    tccount = children.length
    t2 = Tag.find 1
    t2ccount = t2.children.length
    assert t2.children << children
    assert t2.save
    t2.reload
    assert (t2.children.length == tccount + t2ccount)
  end
    
end
