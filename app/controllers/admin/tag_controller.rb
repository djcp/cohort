class Admin::TagController < Admin::ModelAbstractController

  def index
      @tree = Tag.find(:all, :include => [ :children ], :order => :position)
  end

  protected

  def model
    Tag
  end

end
