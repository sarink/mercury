# TODO: Need an entirely new page system

class PagesController < ApplicationController
  Page = Mercury::Page
  History = Mercury::History
  
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  def record_not_found
    render text: "404 Not Found", status: 404
  end
  
  # GET /pages
  # GET /pages.json
  def index
    @page = Page.where(name: "home").first

    respond_to do |format|
      format.html { render :action => "show" }
      format.json { render :json => @page }
    end
  end

  # GET /pages/1
  # GET /pages/1.json
  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @page }
    end
  end
  
  # GET /pages/home
  # GET /pages/home.json
  def showbyname
    @page = Page.where(:name => params[:name]).first
    
    if @page.nil?
      return record_not_found
    else
      respond_to do |format|
       format.html { render :action => "show" }
       format.json { render :json => @page }
      end
    end
  end
  
  # GET /pages/new
  # GET /pages/new.json
  def new
    @page = Page.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @page }
    end
  end

  # GET /pages/1/edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.json
  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        format.html { redirect_to @page, :notice => 'Page was successfully created.' }
        format.json { render :json => @page, :status => :created, :location => @page }
      else
        format.html { render :action => "new" }
        format.json { render :json => @page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.json
  def update
    @page = Page.find(params[:id])
    
    @history = History.new
    @history.user = current_user
    @history.page = @page
    @history.save
    
    @page.regions.each do |region|
      region.update_attributes(params["content"][region.region_name])
      
      # TODO: find a way to get around this
      # because of this bug, region.changed? is always going to return true:
      # https://github.com/rails/rails/issues/8328
      # maybe the client side could determine what's changed and only send that data?
      # maybe we could compare the attributes ourselves to determine?
      # maybe we could not serialize them, but store as normal text, and just use JSON.parse?
        # i think this would break the render_region for snippets (line ~44 of mercury_helper.rb), though.
      # hmm....
      
      # region.assign_attributes(params["content"][region.region_name])
      # if region.changed?
        # @history = History.new
        # @history.user = current_user
        # @history.page = @page
        # @history.region = region
        # @history.region_changes = region.changes
        # if region.save
          # @history.save
        # end
      # end
    end

    respond_to do |format|
      format.html { redirect_to @page, :notice => 'Page was successfully updated.'}
      format.json { head :no_content }
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.json
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to pages_url }
      format.json { head :no_content }
    end
  end
  
end
