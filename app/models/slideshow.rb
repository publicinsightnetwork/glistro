class Slideshow < ActiveRecord::Base
  blameable

  # accessible attributes
  attr_accessible :ident, :title, :desc, :status, :map_type, :map_height, :slide_height

  # constants
  PUBLISHED = 'P'
  DRAFT     = 'D'
  MAP_TYPES = ['stamen-toner', 'stamen-terrain', 'stamen-watercolor', 'mapquest', 'mapquest-aerial']

  # validators
  validates :ident,
    :presence => true,
    :uniqueness => {:case_sensitive => false},
    :length => {:minimum => 3, :maximum => 30},
    :format => {:with => /^[a-zA-Z0-9\-_]+$/, :message => "must be URL-friendly slug!"}
  validates :title,
    :allow_blank => true,
    :length => {:minimum => 1, :maximum => 50}
  validates :desc,
    :allow_blank => true,
    :length => {:minimum => 1, :maximum => 500}
  validates :status,
    :presence => true,
    :inclusion => { :in => [PUBLISHED, DRAFT] }
  validates :map_type,
    :presence => true,
    :inclusion => { :in => MAP_TYPES }
  validates :map_height,
    :presence => true,
    :numericality => {
      :only_integer => true,
      :greater_than => 99,
      :less_than => 1000,
    }
  validates :slide_height,
    :allow_blank => true,
    :numericality => {
      :only_integer => true,
      :greater_than => 49,
      :less_than => 1000,
    }

end
