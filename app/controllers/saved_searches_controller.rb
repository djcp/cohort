class SavedSearchesController < ApplicationController
  before_filter :is_admin

  protect_from_forgery :except => [:auto_complete_for_saved_search_category, :auto_complete_for_saved_search_name]

  auto_complete_for :saved_search, :category
  auto_complete_for :saved_search, :name

  def index
    add_to_sortable_columns('searches', :model => SavedSearch, :field => :category, :alias => :category)
    add_to_sortable_columns('searches', :model => SavedSearch, :field => :name, :alias => :name)
    @saved_searches = SavedSearch.paginate(:page => params[:page], :per_page => 50, :order => sortable_order('searches', :model => SavedSearch, :field => :category, :sort_direction => :desc))
  end

  def new
    @saved_search = SavedSearch.new(:search_url => params[:search_url], :user => @session_user)
    render :template => 'saved_searches/edit' and return 
  end

  def create
    @saved_search = SavedSearch.new(:search_url => params[:search_url], :user => @session_user)
    @saved_search.attributes = params[:saved_search]
    @saved_search.search_url = CGI.unescapeHTML(params[:saved_search][:search_url])
    if @saved_search.save
      flash[:notice] = "We've added that saved search."
      redirect_to @saved_search.search_url and return
    else
      render :template => 'saved_searches/edit'
    end
  end

  def show
    @saved_search = SavedSearch.find(params[:id])
  rescue Exception => exc
    flash[:error] = "There was an error when we looked for that tag: #{exc.message}"
    redirect_to :action => :index and return
  end

  def edit
    @saved_search = SavedSearch.find(params[:id])
    render :template => 'saved_searches/edit' and return 
  end

  def update
    @saved_search = SavedSearch.find(params[:id])
    @saved_search.attributes = params[:saved_search]
    @saved_search.search_url = CGI.unescapeHTML(params[:saved_search][:search_url])
    if @saved_search.save
      flash[:notice] = "we've added that saved search."
      redirect_to @saved_search.search_url and return
    else
      render :template => 'saved_searches/edit'
    end
  end

  def destroy
    @saved_search = SavedSearch.find(params[:id])
    @saved_search.destroy
    flash[:notice] = 'Gone!'
    redirect_to :action => :index and return
  rescue Exception => exc
    logger.error "Destroy failed #{exc.message}"
    flash[:error] = 'There was an error deleting that item. Sorry!'
  end

  def run
    begin
      ss = SavedSearch.find_by_name params[:id]
      ss or raise Exception, "couldn't find that saved search"
      SavedSearchRun.create(:saved_search => ss)
      session[:saved_search_ran] = ss
      redirect_to ss.search_url 
    rescue Exception => exc
        logger.error "Couldn't view that saved search: #{exc.message}"
        flash[:error] = 'There was an error with that saved search. Sorry!'
        redirect_to :action => :index
    end
  end

end
