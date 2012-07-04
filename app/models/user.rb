class User < ActiveRecord::Base
  # Devise setup
  # Unused :token_authenticatable, :encryptable, :lockable, :timeoutable, :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # relationships
  has_many :slideshows, :class_name => "Slideshow", :foreign_key => "blame_cre_by", :dependent => :destroy

  # accessible attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me

end
