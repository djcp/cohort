class NotesController < ApplicationController
  before_filter :is_admin

  def contact
    @contact = Contact.find(params[:id])
    @title = 'Notes for ' + @contact.name_for_display
    @alt_title = nil
    index(true)
  end

  def everyones
    @title = 'Everyone\'s notes'
    @alt_title = 'My notes'
    @alt_action = :my
    index(false)
  end

  def my
    @title = 'My notes'
    @alt_action = :everyones
    @alt_title = 'Everyone\'s notes'
    index(false,true)
  end

  def index(contact_only = false, mine_only = false)
    add_to_sortable_columns('notes', :model => Note, :field => :priority, :alias => :priority)
    add_to_sortable_columns('notes', :model => Note, :field => :contact_id, :alias => :contact)
    add_to_sortable_columns('notes', :model => Note, :field => :follow_up, :alias => :follow_up)
    ferret_fields = (params[:q].blank? ? '* ' : "#{params[:q]} ")
    if contact_only
      #looking for a contact's notes
      ferret_fields += "contact_id: #{params[:id]} "
    elsif mine_only or params[:my]
      #Looking for my notes.
      ferret_fields += "user_id: #{@session_user.id} "
    else
      #looking for everyone's notes. null conditions, just pass in the query. For now.
    end
    if params[:export].blank?
      if ferret_fields == '* '
        @notes = Note.paginate(:page => params[:page], :per_page => 50, :include => [:user => {}, :contact => {:contact_emails => {}}], :order => sortable_order('notes',:model => Note,:field => 'updated_at',:sort_direction => :desc))
      else
        @notes = Note.find_with_ferret(ferret_fields, {:page => params[:page], :per_page => 50},{:include => [:user => {}, :contact =>{:contact_emails => {}}], :order => sortable_order('notes',:model => Note,:field => 'updated_at',:sort_direction => :desc) })
      end
      #logger.warn('fields to ferret: ' + ferret_fields)
      render :action => 'my', :layout => (request.xhr? ? false : true)
    else
      notes = Note.find_with_ferret(ferret_fields, {:limit => :all})
      columns = Note.columns.collect{|c|c.name}
      if params[:export] == 'csv'
        additional_columns = ['primary_email','last_name','first_name']
        columns << additional_columns
        columns.flatten!
        notes.each do |n|
          n['primary_email'] = n.contact.primary_email
          n['last_name'] = n.contact.last_name
          n['first_name'] = n.contact.first_name
        end
        render_csv(:model => Note, :objects => notes, :columns => columns) 
      else
        render :xml => notes.to_xml(:include => {:contact => {:include => [:contact_emails,:tags]},:user => {}})
      end
    end
  end

  def new
    @note = Note.new
    render :template => 'notes/edit' and return 
  end

  def create
    @note = Note.new
    @note.attributes = params[:note]
    if @note.save
      if request.xhr?
        if params[:update_counts_only] == '0'
          render :partial => 'shared/note', :collection => @note.contact.notes, :locals => {:new_object_id => @note.id} 
        else
          render :text =>  @note.contact.notes.count
        end
      else
        flash[:notice] = 'Saved!'
        redirect_to :action => :index and return
      end
    else
      if request.xhr?
        render :text => @note.errors.collect{|attribute,msg| "#{attribute} #{msg}"}.join('<br/>'), :status => 500 and return 
      else
        logger.warn('update failed.')
        render :template => 'notes/edit' and return
      end
    end
  end

  def show
    @note = Note.find(params[:id])
  rescue Exception => exc
    flash[:error] = "There was an error when we looked for that note: #{exc.message}"
    redirect_to :action => :index and return
  end

  def edit
    @note = Note.find(params[:id])
  end

  def update
    @note = Note.find(params[:id])
    @note.attributes = params[:note]
    if @note.save
      if request.xhr?
        if params[:update_counts_only] == '0'
          render :partial => 'shared/note', :collection => @note.contact.notes, :locals => {:new_object_id => @note.id} 
        else
          render :text =>  @note.contact.notes.count
        end
      else
        flash[:notice] = 'Saved!'
        redirect_to :action => :index and return
      end
    else
      if request.xhr?
        render :text => @note.errors.collect{|attribute,msg| "#{attribute} #{msg}"}.join('<br/>'), :status => 500 and return 
      else
        logger.warn('update failed.')
        render :template => 'notes/edit' and return
      end
    end
  end

  def destroy
    begin
      @note = Note.find(params[:id])
      @note.destroy
    rescue Exception => exc
      logger.error "Destroy failed #{exc.message}"
    end
    if params[:redirect_after]
      redirect_to params[:redirect_after]
    else
      render :partial => 'shared/note', :collection => @note.contact.notes, :locals => {:new_object_id => nil}
    end
  end

end
