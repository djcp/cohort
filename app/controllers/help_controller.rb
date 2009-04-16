class HelpController < ApplicationController
  before_filter :ajax_check

  def search_help
    
  end

  def saved_search_help
  end

  def ajax_check
    render :layout => (request.xhr?) ? false : true
  end

end
