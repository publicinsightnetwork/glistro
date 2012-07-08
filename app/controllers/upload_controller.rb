class UploadController < ApplicationController
  before_filter :authenticate_user!

  # GET /upload/1.json
  def show
    @image = Slideimage.where('blame_cre_by = ?', current_user.id).find(params[:id])
    respond_to do |format|
      format.json { render json: @image }
    end
  end

  # POST /upload.json
  def create
    # also need to make sure headers get set correctly: some browsers do the
    # upload in an iframe, and can't handle "app/json".  Use "plain/text" here.
    @image = Slideimage.new(params.select { |k, v| k == 'image' || k == 'slide_id' })

    respond_to do |format|
      if @image.save
        format.json { render :json => @image }
      else
        format.json { render :json => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /upload/1.json
  def destroy
    @image = Slideimage.where('blame_cre_by = ?', current_user.id).find(params[:id])
    @image.destroy
    render :json => true
  end

end
