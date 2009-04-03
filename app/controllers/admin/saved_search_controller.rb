class Admin::SavedSearchController < Admin::ModelAbstractController
  protect_from_forgery :except => [:auto_complete_for_saved_search_category, :auto_complete_for_saved_search_name]

  auto_complete_for :saved_search, :category
  auto_complete_for :saved_search, :name

  def edit
    model = self.model
    @object = model.find_by_id(params[:id]) || model.new(:search_url => params[:search_url], :user => @session_user)
    self.instance_variable_set('@' + @object.class.name.underscore, @object)
    if request.post?
      @object.attributes = params[@object.class.name.underscore]
      @object.search_url = CGI.unescapeHTML(params[:saved_search][:search_url])
      if @object.save
        flash[:notice] = "We've added that saved search."
        redirect_to @object.search_url and return
      end
    end
  end

  def index
    add_to_sortable_columns('searches', :model => SavedSearch, :field => :category, :alias => :category)
    add_to_sortable_columns('searches', :model => SavedSearch, :field => :name, :alias => :name)
    @saved_searches = SavedSearch.paginate(:page => params[:page], :per_page => 50, :order => sortable_order('searches', :model => SavedSearch, :field => :category, :sort_direction => :desc))
  end

  def run
    begin
      ss = SavedSearch.find_by_name params[:id]
      ss or raise Exception, "couldn't find that saved search"
      SavedSearchRun.create(:saved_search => ss)
      redirect_to ss.search_url 
    rescue Exception => exc
        logger.error "Couldn't view that saved search: #{exc.message}"
        flash[:error] = 'There was an error with that saved search. Sorry!'
        redirect_to '/'
    end
  end

  protected
  def model
    SavedSearch
  end

end
