class Admin::ContactController < Admin::ModelAbstractController

  def edit  
    super
  end

  def index
      @contacts = Contact.find :all 
  end

  protected
  def model
    Contact
  end
end
