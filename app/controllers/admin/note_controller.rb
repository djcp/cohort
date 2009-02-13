class Admin::NoteController < Admin::ModelAbstractController 

  def my
    add_to_sortable_columns('notes', :model => Note, :field => :priority, :alias => :priority)
    add_to_sortable_columns('notes', :model => Note, :field => :contact_id, :alias => :contact)
    add_to_sortable_columns('notes', :model => Note, :field => :follow_up, :alias => :follow_up)
    @notes = Note.find(:all,
                       :conditions => ['user_id = ?', @session_user],
                       :order => sortable_order('notes', 
                                                :model => Note, 
                                                :field => 'updated_at',
                                                :sort_direction => :desc
                                               ) 
                      )

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
    render :partial => 'shared/note', :collection => @object.contact.notes, :locals => {:new_object_id => nil} 
  end

  protected
  def model
    Note
  end
end
