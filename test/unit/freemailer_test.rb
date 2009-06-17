require 'test_helper'

class FreemailerTest < ActionMailer::TestCase
  test "from_template" do
    @expected.subject = 'Freemailer#from_template'
    @expected.body    = read_fixture('from_template')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Freemailer.create_from_template(@expected.date).encoded
  end

end
