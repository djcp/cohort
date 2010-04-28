# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '12a66b5d34ef4d039d33ed0d57ad9286'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password, :passwd

  def manage_destination(default_url_hash = {})
    if params[:_redirect_to]
      redirect_to params[:_redirect_to] and return
    elsif ! default_url_hash.blank?
      redirect_to default_url_hash and return
    else 
      redirect_to '/' and return
    end
  end

  protected

  def render_csv(param)
    param[:filebase] = param[:filebase].blank? ? param[:model].to_s.tableize : param[:filebase]

    if param[:columns].blank? 
      param[:columns] = param[:model].columns.collect{|c| c.name}
    end
    csv_string = FasterCSV.generate do |csv|
      csv << param[:columns]
      param[:objects].each do |record|
        line = param[:columns].collect{|col| record[col].to_s.chomp}
        csv << line
      end
    end
    send_data(csv_string,
              :type => 'application/octet-stream',
              :filename => "#{param[:filebase]}-#{Time.now.to_s(:number)}.csv")
  end

  def is_admin
    authenticate_or_request_with_http_basic 'Cohort CRM Management' do |user_name, password|
     u = User.authenticate(user_name,password)
     if u.blank?
      return false
     else
      @session_user = u
     end
    end
  end

end
