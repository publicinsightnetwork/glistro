class Slide < ActiveRecord::Base
  belongs_to :slideshow
  belongs_to :slideimage

  blameable :cascade => [:slideshow]
  acts_as_list :scope => :slideshow
  after_initialize :default_values
  after_save :cleanup_images

  # accessible attributes
  attr_accessible :title, :desc, :position, :layout, :marker_lat, :marker_lng, :slideimage_id

  # constants
  TEXT_ONLY   = 'T'
  LEFT_IMAGE  = 'L'
  RIGHT_IMAGE = 'R'
  FULL_IMAGE  = 'F'

  # validators
  validates :title,
    :allow_blank => true,
    :length => {:minimum => 1, :maximum => 50}
  validates :desc,
    :allow_blank => true,
    :length => {:minimum => 1, :maximum => 500}
  validates :layout,
    :presence => true,
    :inclusion => { :in => [TEXT_ONLY, LEFT_IMAGE, RIGHT_IMAGE, FULL_IMAGE] }

  # include image in json
  def as_json(options={})
    super.as_json(options).merge(
      :slideimage => self.slideimage_id ? self.slideimage.as_json : nil
    )
  end

  private

  def default_values
    self.layout ||= TEXT_ONLY
    self.title  ||= "Lorem ipsum dolor sit amet"
    self.desc   ||= "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

    # give it a random midwestern location
    self.marker_lat ||= (rand * (45-30) + 30)
    self.marker_lng ||= -(rand * (115-80) + 80)
  end

  def cleanup_images
    user_id = self.blame_upd_by || self.blame_cre_by
    cleanup = Slideimage.where('blame_cre_by = ? and id != ?', user_id, self.slideimage_id)
    cleanup.each { |si| si.destroy }
  end

end
