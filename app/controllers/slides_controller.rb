class SlidesController < ApplicationController
  before_filter :lookup_slideshow
  before_filter :lookup_slide, :except => [:index, :create]
  before_filter :authenticate_user!
  before_filter :confirm_owner!

  # lookup owning slideshow
  def lookup_slideshow
    @slideshow = Slideshow.find(params[:slideshow_id])
  end

  # lookup specific slide
  def lookup_slide
    @slide = @slideshow.slides.find(params[:id])
  end

  # confirm that the current user owns the slideshow
  def confirm_owner!
    unless current_user.id == @slideshow.blame_cre_by
      respond_to do |format|
        format.json { head :no_content, :status => :forbidden }
      end
    end
  end

  # GET /slideshows/:slideshow_id/slides.json
  def index
    respond_to do |format|
      format.json { render json: @slideshow.slides }
    end
  end

  # GET /slideshows/:slideshow_id/slides/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @slide }
    end
  end

  # POST /slideshows/:slideshow_id/slides.json
  def create
    @slide = Slide.new(params[:slide])
    @slide.slideshow_id = @slideshow.id

    respond_to do |format|
      if @slide.save
        format.json { render json: @slide, status: :created, location: slideshow_slide_path(@slideshow, @slide) }
      else
        format.json { render json: @slide.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /slideshows/:slideshow_id/slides/1.json
  def update
    respond_to do |format|
      if @slide.update_attributes(params[:slide])
        format.json { head :no_content }
      else
        format.json { render json: @slide.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /slideshows/:slideshow_id/slides/1.json
  def destroy
    @slide.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
