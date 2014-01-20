class Venue < ActiveRecord::Base
  attr_accessible :name, :state, :city, :country
  validates :name, :city, presence: true
  has_many :images
end
