class MercuryController < ActionController::Base
  # include ::Mercury::Authentication

  protect_from_forgery
  # before_filter :authenticate
  before_filter :authenticate_user!
  layout false

  def edit
    render :text => '', :layout => 'mercury' if authenticate
  end

  def resource
    render :action => "/#{params[:type]}/#{params[:resource]}" if authenticate
  end

  def snippet_options
    @options = params[:options] || {}
    render :action => "/snippets/#{params[:name]}/options" if authenticate
  end

  def snippet_preview
    render :action => "/snippets/#{params[:name]}/preview" if authenticate
  end

  def authenticate
    if current_user.admin?
      return true
    else
      render :text => 'You are not an administrator'
      return false
    end
  end

  # def test_page
    # render :text => params
  # end
#
  # private
#
  # def authenticate
    # redirect_to "/#{params[:requested_uri]}" unless can_edit?
  # end
end
