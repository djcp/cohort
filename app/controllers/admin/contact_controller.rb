class Admin::ContactController < Admin::ModelAbstractController

  def manage_tags
    @object = self.model.find_by_id(params[:id])
    new_tags = []
    current_tags = (params[:contact] ? params[:contact][:tag_ids] : [])
    deal_with_new_tags(:tags_to_parse => params[:new_tags],:new_tags => new_tags, :vivify => true)
    deduped_tags = [
      (new_tags and new_tags.collect{|t|t.to_i}),
      (current_tags and current_tags.collect{|t|t.to_i})
    ].flatten.uniq.compact
    logger.warn('Deduped Tags: ' + deduped_tags.inspect)
    @object.tag_ids = deduped_tags || []
    @object.save
    render :partial => 'shared/manage_tags', :layout => (request.xhr? ? false : true), :locals => {:contact_line => @object, :standalone => true}
  end

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
      deal_with_new_tags(:tags_to_parse => params[:new_tags],:new_tags => new_tags, :vivify => true)
      emails = deal_with_email @object
      new_notes = deal_with_notes @object

      deduped_tags = [
        (new_tags and new_tags.collect{|t|t.to_i}),
        (current_tags and current_tags.collect{|t|t.to_i})
      ].flatten.uniq.compact

      logger.warn('Deduped Tags: ' + deduped_tags.inspect)

      @object.tag_ids = deduped_tags || []

      @object.notes << new_notes

      if flash[:ceerror].blank? and @object.save
        unless emails.blank?
          emails.each{|em|
            unless @object.contact_emails.exists?(em)
              @object.contact_emails << em
            end
          }
        end
        @existing_emails_to_destroy.each{|e|e.destroy}
        @object.contact_emails.each{|ce|
          ce.save
        }
        redirect_to :action => :index and return
      end
    end
  end

  def index
    add_to_sortable_columns('contacts', :model => Contact, :field => :last_name, :alias => :last_name)
    add_to_sortable_columns('contacts', :model => Contact, :field => :updated_at, :alias => :updated_at)
    add_to_sortable_columns('contacts', :model => Contact, :field => :country, :alias => :country)
    add_to_sortable_columns('contacts', :model => Contact, :field => :state, :alias => :state)
    ferret_fields = (params[:q].blank? ? '*' : params[:q])

    unless params[:look_in_tags].blank?
    end

    if params[:export].blank?
      @contacts = Contact.find_with_ferret(ferret_fields, {:page => params[:page],:per_page => 50},{:order => sortable_order('contacts',:model => Contact,:field => 'updated_at',:sort_direction => :desc) })
      render :layout => (request.xhr? ? false : true)
    else
      contacts = Contact.find_with_ferret(ferret_fields)
      columns = Contact.columns.collect{|c|c.name}
      if params[:export] == 'csv'
        #De-normalize data because csv files can't be hierarchical like XML.
        additional_columns = ['primary_email','other_emails']
        columns << additional_columns
        columns.flatten!
        contacts.each do |c|
          emails = c.contact_emails.collect{|ce| ce.email}
          c['primary_email'] = c.primary_email
          emails.delete(c.primary_email)
          c['other_emails'] = emails.join(',')
        end
        render_csv(:model => Contact, :objects => contacts, :columns => columns)
      else
        render :xml => contacts.to_xml(:include => [:contact_emails, :notes, :tags])
      end
    end
  end

  protected
  def model
    Contact
  end

  def deal_with_notes(object)
    notes_to_add = []
    if params[:note] && ! params[:note][:note].blank?
      note_to_add = Note.new(:user => @session_user,:contact => object)
      note_to_add.attributes = params[:note]
      if ! note_to_add.valid?
        object.errors.add_to_base(note_to_add.errors.collect{|attribute,msg| "#{attribute}  #{msg}"}.join('<br/>'))
        flash[:error] = (flash[:ceerror].blank? ? '' : flash[:ceerror]) + note_to_add.errors.collect{|attribute,msg| "#{attribute} #{msg}"}.join('<br/>')
      end
      notes_to_add << note_to_add
    end
    return notes_to_add
  end

  def deal_with_email(object)
    flash[:ceerror] = nil
    number_new_emails = params[:new_emails]
    existing_emails = params[:contact_email_ids]
    new_emails = []
    existing_emails = []
    @existing_emails_to_destroy = []
    deduped_emails = []

    #so we need to:
    # Delete existing emails that've been checked as needing deletion
    # Add the new addresses, with some error checking.
    # Ensure that only one address is a primary, across both the new and old addresses.
    # I suspect this will be much easier in rails 2.3 because of the :autosave association attribute.
    # 
    new_email_is_primary = nil

    number_new_emails.each{|i|
      unless params[:new_email][i][:email].blank?
        new_email = {
          :email => params[:new_email][i][:email],
          :email_type => params[:new_email][i][:email_type],
          :is_primary => ((params[:new_email][:is_primary] == i) ? true : false),
          :contact => object
        }
        logger.warn(new_email.inspect + "\n")
        ce = ContactEmail.new(new_email)
        if ! ce.valid? 
          object.errors.add_to_base(ce.errors.collect{|attribute,msg| "#{attribute} #{msg}"}.join('<br/>'))
          flash[:ceerror] = (flash[:ceerror].blank? ? '' : flash[:ceerror]) + ce.errors.collect{|attribute,msg| "#{attribute} #{msg}"}.join('<br/>')
        else
          if ce.is_primary
            new_email_is_primary = true
          end
          deduped_emails << ce
        end
      end
    }

    existing_email_is_primary = nil
    object.contact_emails.each{|ce|
      if params[:contact_email][ce.id.to_s][:delete].to_i == 1
        @existing_emails_to_destroy << ce
      else
        ce.email = params[:contact_email][ce.id.to_s][:email]
        ce.email_type = params[:contact_email][ce.id.to_s][:email_type]

        if new_email_is_primary
          ce.is_primary = false
        else
          ce.is_primary = ((params[:contact_email][:is_primary].to_i == ce.id) ? true : false)
        end

        if ! ce.valid?
          object.errors.add_to_base(ce.errors.collect{|attribute,msg| "#{attribute}  #{msg}"}.join('<br/>'))
          flash[:error] = (flash[:ceerror].blank? ? '' : flash[:ceerror]) + ce.errors.collect{|attribute,msg| "#{attribute} #{msg}"}.join('<br/>')
        end
        existing_emails << ce
      end
    }
    deduped_emails << existing_emails
    deduped_emails.flatten!

    has_primary = false
    deduped_emails.collect{|ce| has_primary = ce.is_primary}
    unless has_primary
      unless deduped_emails.blank?
        deduped_emails.first.is_primary = true
      end
    end
    return deduped_emails

  end

  # This will auto-vivify tags that we haven't seen yet.
  def deal_with_new_tags(param)
    param[:tags_to_parse].split(',').each do |tag|
      matchval = tag.match(/\(id\:(\d+)\)$/)
      if matchval
        param[:new_tags] << matchval[1].to_i
        #FIXME
      elsif param[:vivify] && param[:vivify] == true
        begin
          unless tag.blank?
            nt = Tag.create(:tag => tag)
            param[:new_tags] << nt.id
          end
        rescue Exception => exc
          flash[:ceerror] = "There was an error creating that tag: #{exc.message}"
        end
      end
    end
  end

end
