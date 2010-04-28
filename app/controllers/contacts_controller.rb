class ContactsController < ApplicationController
  before_filter :is_admin

  def manage_notes
    @contact = Contact.find(params[:id])
    render :partial => 'shared/manage_notes', :layout => (request.xhr? ? false : true)
  end

  def manage_tags
    @object = Contact.find_by_id(params[:id])
    if request.post?
      new_tags = []
      current_tags = (params[:contact] ? params[:contact][:tag_ids] : [])
      parse_tag_list(:tags_to_parse => params[:new_tags],:tag_list => new_tags, :autocreate => true)
      deduped_tags = [
        (new_tags and new_tags.collect{|t|t.to_i}),
        (current_tags and current_tags.collect{|t|t.to_i})
      ].flatten.uniq.compact
      #logger.warn('Deduped Tags: ' + deduped_tags.inspect)
      @object.tag_ids = deduped_tags || []
      @object.save
    end
    render :partial => 'shared/manage_tags', :layout => (request.xhr? ? false : true), :locals => {:contact_line => @object, :standalone => true}
  end

  def index
    add_to_sortable_columns('contacts', :model => Contact, :field => :last_name, :alias => :last_name)
    add_to_sortable_columns('contacts', :model => Contact, :field => :updated_at, :alias => :updated_at)
    add_to_sortable_columns('contacts', :model => Contact, :field => :country, :alias => :country)
    add_to_sortable_columns('contacts', :model => Contact, :field => :state, :alias => :state)
    ferret_fields = (params[:q].blank? ? '*' : params[:q]) + ' '

    if params[:tags_to_include] or params[:included_tags]
      include_tags = []
      existing_included_tags = params[:included_tags]
      parse_tag_list(:tags_to_parse => params[:tags_to_include] || '', :tag_list => include_tags, :autocreate => false)
      @included_tags_for_output = [existing_included_tags,include_tags].flatten.uniq.compact.collect{|tid| Tag.find(tid.to_i)} ||[]

      tags_to_search_for = []
      @included_tags_for_output.each do |tag|
        tags_to_search_for << tag.descendants
      end
      final_tags_to_include = [tags_to_search_for,@included_tags_for_output].flatten.uniq.compact
      unless final_tags_to_include.blank?
        ferret_fields += " (" + (final_tags_to_include.collect{|tid| "my_tag_ids:#{tid.id}"}.join(' OR ')) + ") "
      end
    end

    if params[:tags_to_exclude] or params[:excluded_tags]
      exclude_tags = []
      @excluded_tags_for_output = []
      existing_excluded_tags = params[:excluded_tags]
      parse_tag_list(:tags_to_parse => params[:tags_to_exclude], :tag_list => exclude_tags, :autocreate => false)
      @excluded_tags_for_output = [existing_excluded_tags,exclude_tags].flatten.uniq.compact.collect{|tid| Tag.find(tid.to_i)} ||[]
      tags_to_exclude = []
      @excluded_tags_for_output.each do |tag|
        tags_to_exclude << tag.descendants
      end
      final_tags_to_exclude = [@excluded_tags_for_output,tags_to_exclude].flatten.uniq.compact
      unless final_tags_to_exclude.blank?
        ferret_fields += ' (' + (final_tags_to_exclude.collect{|tid| "-my_tag_ids:#{tid.id}"}.join(' OR ')) + ') '
      end
    end

    #logger.warn("Ferret search string: " + ferret_fields)

    if params[:export].blank?
      if ferret_fields == '* '
        @contacts = Contact.paginate(:page => params[:page],:per_page => 50,:include => [:notes, :contact_emails,:tags], :order => sortable_order('contacts',:model => Contact,:field => 'updated_at',:sort_direction => :desc))
      else
        @contacts = Contact.find_with_ferret(ferret_fields, {:page => params[:page],:per_page => 50},{:include => [:notes, :contact_emails, :tags], :order => sortable_order('contacts',:model => Contact,:field => 'updated_at',:sort_direction => :desc) })
      end
      render :layout => (request.xhr? ? false : true)
    else
      contacts = Contact.find_with_ferret(ferret_fields, {:limit => :all})
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

  def new
    @contact = Contact.new
    [1,2].each do |i|
      @contact.contact_addresses.build
      @contact.contact_emails.build
      @contact.contact_urls.build
      @contact.contact_phones.build
    end
    render :template => 'contacts/edit' and return 
  end

  def create
    @contact = Contact.new
    @contact.attributes = params[:contact]
    if @contact.save
      manage_destination(:controller => '/admin/dashboard', :action => :dashboard)
    else
      render :template => 'contacts/edit' and return
    end
  end

  def show
    @contact = Contact.find(params[:id])
  rescue Exception => exc
    flash[:error] = "There was an error when we looked for that contact: #{exc.message}"
    manage_destination(:controller => '/admin/dashboard', :action => :dashboard)
  end

  def edit
    @contact = Contact.find(params[:id])
    [1,2].each do |i|
      @contact.contact_addresses.build
      @contact.contact_emails.build
      @contact.contact_urls.build
      @contact.contact_phones.build
    end
  end

  def update
    @contact = Contact.find(params[:id])
    @contact.attributes = params[:contact]
    if @contact.save
      flash[:notice] = 'Saved!'
      manage_destination(:controller => '/admin/dashboard', :action => :dashboard)
    else
      #logger.warn('update failed.')
      render :template => 'contacts/edit' and return
    end
  end

  def destroy
    begin
      @contact = Contact.find(params[:id])
      @contact.destroy
      flash[:notice] = 'Gone!'
      manage_destination(:controller => '/admin/dashboard', :action => :dashboard)
    rescue Exception => exc
      #logger.error "Destroy failed #{exc.message}"
      flash[:error] = 'There was an error deleting that item. Sorry!'
    end
  end

  def parse_tag_list(param)
    param[:tags_to_parse] ||= ''
    param[:tags_to_parse].split(',').each do |tag|
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
