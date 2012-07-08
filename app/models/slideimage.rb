class Slideimage < ActiveRecord::Base
  belongs_to :slide

  blameable :cascade => [:slide]
  has_attached_file :image, :styles => { :wide => "800", :medium => "400", :square => "300x300#" }

  # accessible attributes
  attr_accessible :image

  # validators
  validates_attachment :image,
    :presence => true,
    :content_type => { :content_type => ['image/jpeg', 'image/png', 'image/gif'] },
    :size => { :in => 0..5.megabytes }

end
