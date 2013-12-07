class TemplatesController < ApplicationController
  # This is our new function that comes before Devise's one
  before_filter :authenticate_user_from_token!
  
  before_filter :authenticate_user!

  def index

  end

  def template
    render :template => 'templates/' + params[:path], :layout => nil
  end

end
