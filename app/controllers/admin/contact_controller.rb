class Admin::ContactController < Admin::ModelAbstractController

  def edit 
    @use_fckeditor = true
    model = self.model
    @object = model.find_by_id(params[:id]) || model.new

    #Copy the object to a class-specific instance variable so we can have easier-to-use edit and management forms.
    self.instance_variable_set('@' + @object.class.name.downcase, @object)
    if request.post?
      @object.attributes = params[@object.class.name.downcase]
      current_tags = params[:contact][:tag_ids]

      new_tags = []
      deal_with_new_tags(params[:new_tags],new_tags)

      deal_with_email(@object)

      deduped_tags = [new_tags,current_tags].flatten.uniq
      logger.warn(deduped_tags.inspect)
      @object.tag_ids = deduped_tags || []

      if @object.save
        redirect_to :action => :index and return
      end
    end
  end

  def index
      @contacts = Contact.find :all 
  end

  protected
  def model
    Contact
  end

  def deal_with_email(object)
    number_new_emails = params[:new_emails]
    existing_emails = params[:contact_email_ids]
    #so we need to:
    # Delete existing emails that've been checked as needing deletion
    # Add the new addresses, with some error checking.
    # Ensure that only one address is a primary, across both the new and old addresses.

  end

  def deal_with_new_tags(new_tags_string,new_tags)
    new_tags_string.split(',').each{|tag|
      matchval = tag.match(/\(id\:(\d+)\)$/)
      if matchval
        new_tags << matchval[1].to_i
      else
        begin
          unless tag.blank?
            nt = Tag.create(:tag => tag)
            new_tags << nt.id
          end
        rescue Exception => exc
          flash[:error] = "There was an error creating that tag: #{exc.message}"
        end
      end
    }
    return new_tags
  end

end
