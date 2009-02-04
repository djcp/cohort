require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  test 'has natural relations' do
    n = get_a_note
    assert_respond_to n, :user 
    assert_respond_to n, :contact 
  end

  test "can create note" do
    u = get_a_user
    c = get_a_contact
    n = Note.new :user => u, :contact => c
    n.note = 'You are a very odd person.'
    assert n.save
  end

  test 'acts as a list' do
    n = get_a_note
    n2 = get_another_note
    assert_respond_to n, :move_lower
    assert n.position == 1
    assert n2.position == 2

    n.move_lower
    assert n.save

    #Have to reload the second note object because "position" is cached in ruby-space.
    n2.reload

    assert n.position == 2
    assert n2.position == 1
  end

  test 'needs a note' do
    n = get_a_note
    n.note = nil
    assert (! n.valid?)
  end

end
