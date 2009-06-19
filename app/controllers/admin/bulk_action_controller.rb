class Admin::BulkActionController < Admin::BaseController

  def bulk_note
    if request.post?
      begin
        contact_ids = params[:contact_ids]
        contact_ids.each do |cid|
          n = Note.new( :user_id => @session_user.id, :note => params[:note], :priority => params[:priority].to_i, :follow_up => params[:follow_up], :contact_id => cid)
          n.save
        end
      rescue Exception => exc
        flash[:error] = "There was an error creating some notes: #{exc.message}"
      end
    end
    redirect_to params[:return_to] and return
  end

  def bulk_tag_remove
    if request.post?
    tags = []
      parse_bulk_tag_list(:tags => params[:bulk_remove_tags], :tag_list => tags, :autocreate => false)
      contact_ids = params[:contact_ids]
      Contact.find_all_by_id(contact_ids).each do |c|
        ctids = c.tag_ids
        tags.each do |t|
          ctids.delete(t)
        end
        c.tag_ids = ctids
      end
      Contact.bulk_index(contact_ids)
      flash[:notice] = 'Those tags have been removed.'
    end
    redirect_to params[:return_to] and return
  end

  def bulk_contact_delete
    if request.post?
      contact_ids = params[:contact_ids]
      begin
        Contact.find(contact_ids).each do |c|
          c.destroy
        end
      rescue Exception => exc
          flash[:error] = "There was an error creating that tag: #{exc.message}"
      end
      flash[:notice] = 'Those contacts have been permanently deleted.'
    end
    redirect_to params[:return_to] and return
  end

  def bulk_tag
    if request.post?
      new_tags = []
      parse_bulk_tag_list(:tags => params[:bulk_apply_tags], :tag_list => new_tags, :autocreate => true)
      contact_ids = params[:contact_ids]
      Contact.find_all_by_id(contact_ids, :include => :tags).each do |c|
        tag_ids = c.tag_ids
        tag_ids << new_tags
        c.tag_ids = tag_ids.uniq.compact
      end
      Contact.bulk_index(contact_ids)
      flash[:notice] = 'Those contacts have been tagged.'
    end
    redirect_to params[:return_to] and return
  end

  protected

  def parse_bulk_tag_list(param)
    param[:tags].split(',').each do |tag|
      matchval = tag.match(/\(id\:(\d+)\)$/)
      if matchval
        param[:tag_list] << matchval[1].to_i
      elsif param[:autocreate] && param[:autocreate] == true
        begin
          unless tag.blank?
            nt = Tag.create(:title => tag)
            param[:tag_list] << nt.id
          end
        rescue Exception => exc
          flash[:ceerror] = "There was an error creating that tag: #{exc.message}"
        end
      end
    end
  end

end
