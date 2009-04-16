class StaticPagesController < ApplicationController
  def search_help
    render :layout => (request.xhr?) ? false : true
  end
end
