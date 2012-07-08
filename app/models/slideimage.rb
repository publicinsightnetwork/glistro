class Slideimage < ActiveRecord::Base
  has_one :slide

  blameable :cascade => [:slide]
  has_attached_file :image, :styles => { :wide => "800", :medium => "400", :square => "300x300#" }

  # accessible attributes
  attr_accessible :image

  # validators
  validates_attachment :image,
    :presence => true,
    :content_type => { :content_type => ['image/jpeg', 'image/png', 'image/gif'] },
    :size => { :in => 0..5.megabytes }

  # include image in json
  def as_json(options={})
    super.as_json(options).merge(
      :url         => self.image.url,
      :wide_url    => self.image.url(:wide),
      :medium_url  => self.image.url(:medium),
      :square_url  => self.image.url(:square),
      :delete_url  => "/upload/#{self.id}",
    )
  end

end
