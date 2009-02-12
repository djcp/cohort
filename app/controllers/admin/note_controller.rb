class Admin::NoteController < Admin::ModelAbstractController 

  def edit
    @dont_redirect = true
    super
    if request.xhr? 
      if @object.valid?
        if params[:update_counts_only] == '0'
          render :partial => 'shared/note', :collection => @object.contact.notes, :locals => {:new_object_id => @object.id} 
        else
          render :text =>  "#{@object.contact.notes.count} notes" 
        end
      else
        render :text => "We can't add empty notes. Please try again.", :status => 500 and return 
      end
    end
  end

  def destroy
    if request.post?
      begin
        @object = self.model.find(params[:id])
        @object.destroy
      rescue Exception => exc
        logger.error "Destroy failed #{exc.message}"
      end
    end
    render :partial => 'shared/note', :collection => @object.contact.notes, :locals => {:new_object_id => nil} 
  end

  protected
  def model
    Note
  end
end
