require 'test_helper'

class TagTest < ActiveSupport::TestCase

  test "tag acts as list" do
    t = get_a_tag
    assert_respond_to t, :move_higher
  end

  test "tag acts as tree" do
    t = get_a_tag
    assert_respond_to t, :children
  end

  test "tag can have a contact" do
    c = get_a_contact
    t = get_a_tag
    assert c.tags.length == 0
    c.tags = [t]
    assert c.save
    assert c.tags.length == 1
  end

  test "can delete tag" do
    c = get_a_contact
    t = get_a_tag
    c.tags = [t]
    c.save
    assert c.tags.length == 1
    assert t.destroy
    c.reload
    assert c.tags.length == 0
  end

  test "can delete a contact with a tag" do
    c = get_a_contact
    t = get_a_tag
    c.tags = [t]
    c.save
    c.reload
    assert c.destroy
  end

  test "can reorder tags" do
    t = Tag.find 5
    assert t.position == 1
    assert t.move_lower
    t.reload
    assert t.position == 2
  end

  test "tag has children" do
    t = Tag.find 4
    assert t.children.length == 2
  end

  test "can reassign parent" do
    t = Tag.find 5
    tparent = Tag.find 1
    t.parent = tparent
    assert t.save
    t.reload
    tparent.reload
    assert tparent.children.find(t)
  end

  test "can orphan tag" do
    t = Tag.find 5
    t.parent = nil
    assert t.save
    t.reload
    assert t.parent == nil
  end

  test "can mass reassign children" do
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
