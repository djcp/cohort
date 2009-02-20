class Admin::NoteController < Admin::ModelAbstractController 

  def contact
    @contact = Contact.find(params[:id])
    @title = 'Notes for ' + @contact.name_for_display
    note_engine(true)
  end

  def everyones
    @title = 'Everyone\'s notes'
    note_engine(false,true)
  end

  def my
    @title = 'My notes'
    note_engine
  end

  def note_engine(contact_only = false, all_users = false)
    add_to_sortable_columns('notes', :model => Note, :field => :priority, :alias => :priority)
    add_to_sortable_columns('notes', :model => Note, :field => :contact_id, :alias => :contact)
    add_to_sortable_columns('notes', :model => Note, :field => :follow_up, :alias => :follow_up)
    ferret_fields = (params[:q].blank? ? '*' : params[:q])
    if contact_only
      #looking for a contact's notes
      ferret_fields += " contact_id: #{params[:id]} "
    elsif all_users
      #looking for everyone's notes. null conditions, just pass in the query. For now.
    else
      #Looking for my notes.
      ferret_fields += " user_id: #{@session_user.id} "
    end
    @notes = Note.find_with_ferret(ferret_fields, {:page => params[:page], :per_page => 50},{:order => sortable_order('notes',:model => Note,:field => 'updated_at',:sort_direction => :desc) })
    render :action => 'my', :layout => (request.xhr? ? false : true)
  end

  def edit
    @dont_redirect = true
    super
    if request.xhr? 
      if @object.valid?
        if params[:update_counts_only] == '0'
          render :partial => 'shared/note', :collection => @object.contact.notes, :locals => {:new_object_id => @object.id} 
        else
          render :text =>  @object.contact.notes.count
        end
      else
        render :text => @object.errors.collect{|attribute,msg| "#{attribute} #{msg}"}.join('<br/>'), :status => 500 and return 
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
    if params[:redirect_after]
      redirect_to params[:redirect_after]
    else
      render :partial => 'shared/note', :collection => @object.contact.notes, :locals => {:new_object_id => nil}
    end
  end

  protected
  def model
    Note
  end
end
