class Profile < ActiveRecord::Base
  attr_accessible :age, :gender, :dob, :city, :avatar, :first_name, :last_name

  has_attached_file :avatar, :styles => { :square => "75x75>", :thumb => "100x67>", :small => "240x161>", :medium => "500x334>", :large => "1024x768>"}
  belongs_to :user

  validates :first_name, :gender, presence: true
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/png']
end
