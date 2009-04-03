class Admin::TagController < Admin::ModelAbstractController
  protect_from_forgery :except => :json_tags

  def edit
    super(:parent_id => params[:parent_id])
  end

  def parse_bulk_tag_list(param)
    param[:tags].split(',').each do |tag|
      matchval = tag.match(/\(id\:(\d+)\)$/)
      if matchval
        param[:tag_list] << matchval[1].to_i
      else
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

  def bulk_tag
    new_tags = []
    parse_bulk_tag_list(:tags => params[:new_tags], :tag_list => new_tags)
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
    redirect_to :controller => '/admin/contact', :action => :index and return
  end

  def index
      @tree = Tag.find(:all, :include => [ :children ], :order => :position)
  end

  def json_tags
    tags = Tag.find(:all, :conditions => ["lower(tag) like lower(?)", '%' + params[:search] + '%'], :limit => params[:max] || 20)
    render  :json => tags.collect{|t| {'text' => t.hierarchical_title , 'value' => t['id']}}.to_json 
  end

  protected

  def model
    Tag
  end

end
