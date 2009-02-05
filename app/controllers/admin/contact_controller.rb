class Admin::ContactController < Admin::ModelAbstractController

  def index
      @contacts = Contact.find :all 
  end

  protected
  def model
    Contact
  end
end
