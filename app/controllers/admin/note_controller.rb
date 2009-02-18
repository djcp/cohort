class Admin::NoteController < Admin::ModelAbstractController 

  def contact
    begin
      @contact = Contact.find(params[:id])
      @title = 'Notes for ' + @contact.name_for_display
      note_engine(true)
    rescue Exception => exc
      logger.error "I couldn't do that: #{exc.message}"
    end
  end

  def my
    @title = 'My notes'
    note_engine
  end

  def note_engine(contact_only = false)
    add_to_sortable_columns('notes', :model => Note, :field => :priority, :alias => :priority)
    add_to_sortable_columns('notes', :model => Note, :field => :contact_id, :alias => :contact)
    add_to_sortable_columns('notes', :model => Note, :field => :follow_up, :alias => :follow_up)
    
    conditions_fields = [' user_id = ? ']
    conditions_params = [@session_user]

    if contact_only
      conditions_fields << 'contact_id = ?'
      conditions_params << params[:id]
    end

    unless params[:q].blank?
      conditions_fields << ' lower(note) like ? '
      conditions_params << "#{params[:anywhere] ? '%' : ''}#{params[:q].downcase}%"
    end

    @notes = Note.find(:all,
                       :conditions => [conditions_fields.join(' and '),conditions_params].flatten,
                       :order => sortable_order('notes', 
                                                :model => Note, 
                                                :field => 'updated_at',
                                                :sort_direction => :desc
                                               ) 
                      )
    render :action => 'my', :layout => (request.xhr? ? false : true)
  end

  def everyones
  end

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
    #FIXME
    render :partial => 'shared/note', :collection => @object.contact.notes, :locals => {:new_object_id => nil} 
  end

  protected
  def model
    Note
  end
end
