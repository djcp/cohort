class TagsController < ApplicationController
  before_filter :is_admin
  protect_from_forgery :except => :json_tags

  def json_tags
    tags = Tag.find(:all, :conditions => ["lower(tag_path) like lower(?)", '%' + params[:search] + '%'], :limit => params[:max] || 20)
    render  :json => tags.collect{|t| {'text' => t.tag_path , 'value' => t['id']}}.to_json 
  end

  def move_higher
    @tag = Tag.find params[:id]
    @tag.move_higher
    flash[:notice] = 'Moved!'
    redirect_to :action => :index
  rescue Exception => exc
    logger.error "Move failed #{exc.message}"
    flash[:error] = "There was an error when I attempted to move that item. Sorry!"
  end

  def move_lower
    @tag = Tag.find params[:id]
    @tag.move_lower
    flash[:notice] = 'Moved!'
    redirect_to :action => :index
  rescue Exception => exc
    logger.error "Move failed #{exc.message}"
    flash[:error] = "There was an error when I attempted to move that item. Sorry!"
  end

  def index
      @tree = Tag.find(:all, :include => [ :children ], :order => :position)
  end

  def new
    @tag = Tag.new
    render :template => 'tags/edit' and return 
  end

  def create
    @tag = Tag.new
    @tag.attributes = params[:tag]
    if @tag.save
      redirect_to :action => :index and return
    else
      render :template => 'tags/edit' and return
    end
  end

  def show
    @tag = Tag.find(params[:id])
  rescue Exception => exc
    flash[:error] = "There was an error when we looked for that tag: #{exc.message}"
    redirect_to :action => :index and return
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.attributes = params[:tag]
    if @tag.save
      flash[:notice] = 'Saved!'
      redirect_to :action => :index and return
    else
      logger.warn('update failed.')
      render :template => 'tags/edit' and return
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    flash[:notice] = 'Gone!'
    redirect_to :action => :index and return
  rescue Exception => exc
    logger.error "Destroy failed #{exc.message}"
    flash[:error] = 'There was an error deleting that item. Sorry!'
  end

end
