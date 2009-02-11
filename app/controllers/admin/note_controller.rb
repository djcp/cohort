class Admin::NoteController < Admin::ModelAbstractController 

  def edit
    super
    # FIXME - remove redirection from the base class for finer control over post-action destinations.
    if request.xhr?
      list and return
    end
  end

  def list
    @notes = Note.find(:all, :conditions => ['contact_id = ?', params[:note][:contact_id]], :order => 'created_at desc')
  end

  protected
  def model
    Note
  end
end
