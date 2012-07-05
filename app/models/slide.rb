class Slide < ActiveRecord::Base
  belongs_to :slideshow

  blameable :cascade => [:slideshow]
  acts_as_list :scope => :slideshow
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  after_initialize :default_values

  # accessible attributes
  attr_accessible :title, :desc, :image, :position, :layout, :marker_lat, :marker_lng

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

  # transate to an object config
  def to_config
    {
      :marker => self.marker_lat ? [self.marker_lat, self.marker_lng] : nil,
      :center => nil, #TODO
      :html   => 'hello world',
      :popup  => 'hello world',
    }
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

end
