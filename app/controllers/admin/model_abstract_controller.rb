class Admin::ModelAbstractController < Admin::BaseController

  def move_higher
    move('move_higher')
  end

  def move_lower
    move('move_lower')
  end

  def destroy
    if request.post?
      begin
        @object = self.model.find(params[:id])
        @object.destroy
        flash[:notice] = 'Gone!'
      rescue Exception => exc
        logger.error "Destroy failed #{exc.message}"
        flash[:error] = 'There was an error deleting that item. Sorry!'
      end
    else
      flash[:notice] = "Not deleted."
    end
    redirect_to :action => :index and return
  end

  def edit(default_new_object_attributes = {})
    @use_fckeditor = true
    model = self.model
    @object = model.find_by_id(params[:id]) || model.new(default_new_object_attributes)

    #Copy the object to a class-specific instance variable so we can have easier-to-use edit and management forms.
    self.instance_variable_set('@' + @object.class.name.downcase, @object)

    # This is an admin-only way of assigning attributes to 
    # objects. We need to protect methods if we're going to expose
    # objects to editing by non-admin users.
    if request.post?
      if @object.respond_to?('move_higher')
        @object['original_parent_id'] = @object.parent_id
      end
      @object.attributes = params[@object.class.name.downcase]
      if @object.save
        redirect_to :action => :index and return
      end
    end
  end

  protected

  def move(move_method = 'move_higher')
    begin
      @object = self.model.find(params[:id])
      unless @object.respond_to?(move_method)
        raise "You can't move this kind of object" 
      end
      @object.send(move_method)
      @object.reload
      flash[:notice] = 'Moved!'
    rescue Exception => exc
      logger.error "Move failed #{exc.message}"
      flash[:error] = 'There was an error moving that item. Sorry!'
    end
    redirect_to :action => :index and return
  end

end
