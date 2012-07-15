class HomeController < ApplicationController

  # GET /
  # GET /.json
  def index
    if user_signed_in?
      @slideshows = Slideshow.where('blame_cre_by = ?', current_user.id).order('blame_cre_at desc').limit(10)
    else
      # @slideshows = Slideshow.where('status = ?', Slideshow::PUBLISHED)
      render 'splash' and return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @slideshows }
    end
  end

end
