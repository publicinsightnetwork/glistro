class UploadController < ApplicationController
  before_filter :authenticate_user!

  # GET /upload/1.json
  def show
    @image = Slideimage.where('blame_cre_by = ?', current_user.id).find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: to_jq_upload(@image) }
    end
  end

  # POST /upload.json
  def create
    # also need to make sure headers get set correctly: some browsers do the
    # upload in an iframe, and can't handle "app/json".  Use "plain/text" here.
    @image = Slideimage.new(params[:upload])

    respond_to do |format|
      if @image.save
        format.json { render :json => to_jq_upload(@image) }
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

  private

  def to_jq_upload(image)
    fmt = I18n.t "date.formats.form"
    image.as_json.merge(
      :url         => image.photo.url,
      :wide_url    => image.photo.url(:wide),
      :medium_url  => image.photo.url(:medium),
      :square_url  => image.photo.url(:square),
      :delete_url  => "/upload/#{image.id}",
    )
  end

end
