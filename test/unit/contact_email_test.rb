require 'test_helper'

class ContactEmailTest < ActiveSupport::TestCase

  test "contact email unique among a contact" do
    ce = ContactEmail.find_by_email('djcp@example.com')
    c = ce.contact

    ce2 = ContactEmail.new(
      :email=> 'djcp@example.com', 
      :contact_id => c.id,
      :email_type => 'work'
      )
    if ce2.valid?
      assert false
    else
      assert true
    end
  end

  test "contact email can be a dupe globally" do
    c = Contact.find 2
    if ! c.contact_emails.find_by_email('djcp@example.com')
      assert true
    end
    ce2 = ContactEmail.new(
      :email=> 'djcp@example.com', 
      :contact_id => c.id,
      :email_type => 'work'
      )
    if ce2.valid?
      assert true
    else
      assert false
    end
  end

  test "can only set valid email types" do
    ce = ContactEmail.find :first
    ce.email_type = 'sdflkjsdlfkjdsf'
    assert true if ! ce.valid?

    ContactEmail::EMAIL_TYPES.keys.each do|cetype|
      ce.email_type = cetype
      assert ce.valid?
    end
  end

  test "can only have email-y email addresses " do
    good = %W|dan@example.com dan@foo.com goe.sdf@basdrr.cc bafd+sef@bdf.com bafs@sdlkfjdsf-sdf.sdfsdf-sdf.co|
    bad = %W|bar foo@ foo.bar@cc.c bsdf@ddf.c|

    ce = ContactEmail.find :first

    good.each do|email|
      ce.email = email
      assert ce.valid?
    end

    bad.each do|email|
      ce.email = email 
      if ce.valid?
        assert false
      else
        assert true
      end
    end
  end

end
