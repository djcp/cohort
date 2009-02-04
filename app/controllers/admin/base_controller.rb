class Admin::BaseController < ApplicationController
  before_filter :is_admin
end
