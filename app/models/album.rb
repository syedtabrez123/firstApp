class Album < ActiveRecord::Base
  attr_accessible :user_id, :images_attributes, :name
  belongs_to :user
  has_many :images, :dependent => :destroy
  accepts_nested_attributes_for :images , :reject_if => lambda { |a| a[:photo].blank? }, :allow_destroy => true
  #attr_accessor :location
  validates :name , presence: true
end
