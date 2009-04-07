class Admin::BulkActionController < Admin::BaseController

  def parse_bulk_tag_list(param)
    param[:tags].split(',').each do |tag|
      matchval = tag.match(/\(id\:(\d+)\)$/)
      if matchval
        param[:tag_list] << matchval[1].to_i
      elsif param[:vivify] && param[:vivify] == true
        begin
          unless tag.blank?
            nt = Tag.create(:tag => tag, :parent => Tag.get_uncategorized_root_tag)
            param[:tag_list] << nt.id
          end
        rescue Exception => exc
          flash[:ceerror] = "There was an error creating that tag: #{exc.message}"
        end
      end
    end
  end

  def bulk_tag_remove
    tags = []
    parse_bulk_tag_list(:tags => params[:bulk_remove_tags], :tag_list => tags, :vivify => false)
    contact_ids = params[:contact_ids]
    contact_ids.each do |cid|
      c = Contact.find_by_id cid
      if c == nil
        next
      end
      #FIXME
      c.tag_ids = tag_ids.uniq.compact
    end
    flash[:notice] = 'Those contacts have been tagged.'
    redirect_to params[:return_to] and return
  end

  def bulk_tag
    new_tags = []
    parse_bulk_tag_list(:tags => params[:bulk_apply_tags], :tag_list => new_tags, :vivify => true)
    contact_ids = params[:contact_ids]
    contact_ids.each do |cid|
      c = Contact.find_by_id cid
      if c == nil
        next
      end
      tag_ids = c.tag_ids
      tag_ids << new_tags
      c.tag_ids = tag_ids.uniq.compact
      c.save
    end
    flash[:notice] = 'Those contacts have been tagged.'
    redirect_to params[:return_to] and return
  end

end
