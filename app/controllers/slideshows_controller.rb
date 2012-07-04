class SlideshowsController < ApplicationController
  before_filter :lookup, :except => [:index, :new, :create]
  before_filter :authenticate_user!, :only => [:new, :edit, :update, :destroy]
  before_filter :confirm_owner!, :only => [:edit, :update, :destroy]

  # lookup slideshow
  def lookup
    if user_signed_in?
      @slideshow = Slideshow.where('status = ? or blame_cre_by = ?',
        Slideshow::PUBLISHED, current_user.id).find(params[:id])
    else
      @slideshow = Slideshow.where('status = ?', Slideshow::PUBLISHED)
        .find(params[:id])
    end
  end

  # confirm that the current user owns the slideshow
  def confirm_owner!
    unless current_user.id == @slideshow.blame_cre_by
      respond_to do |format|
        format.html { render :text => 'Action not allowed', :status => :forbidden }
        format.json { head :no_content, :status => :forbidden }
      end
    end
  end

  # GET /slideshows
  # GET /slideshows.json
  def index
    if user_signed_in?
      @slideshows = Slideshow.where('status = ? or blame_cre_by = ?',
        Slideshow::PUBLISHED, current_user.id)
    else
      @slideshows = Slideshow.where('status = ?', Slideshow::PUBLISHED)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @slideshows }
    end
  end

  # GET /slideshows/1
  # GET /slideshows/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @slideshow }
    end
  end

  # GET /slideshows/new
  # GET /slideshows/new.json
  def new
    @slideshow = Slideshow.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @slideshow }
    end
  end

  # GET /slideshows/1/edit
  def edit
  end

  # POST /slideshows
  # POST /slideshows.json
  def create
    @slideshow = Slideshow.new(params[:slideshow])

    respond_to do |format|
      if @slideshow.save
        format.html { redirect_to @slideshow, notice: 'Slideshow was successfully created.' }
        format.json { render json: @slideshow, status: :created, location: @slideshow }
      else
        format.html { render action: "new" }
        format.json { render json: @slideshow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /slideshows/1
  # PUT /slideshows/1.json
  def update
    respond_to do |format|
      if @slideshow.update_attributes(params[:slideshow])
        format.html { redirect_to @slideshow, notice: 'Slideshow was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @slideshow.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /slideshows/1
  # DELETE /slideshows/1.json
  def destroy
    @slideshow.destroy

    respond_to do |format|
      format.html { redirect_to slideshows_url }
      format.json { head :no_content }
    end
  end
end
