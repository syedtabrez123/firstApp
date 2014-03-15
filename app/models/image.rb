class Image < ActiveRecord::Base
  attr_accessible :album_id, :photo, :venue_id
  belongs_to :album
  belongs_to :venue

  has_attached_file :photo, :styles => { :square => "75x75>", :thumb => "100x67>", :small => "240x161>", :medium => "500x334>", :large => "1024x768>"}# , :path => ":rails_root/public/images/:id/:style/:basename.:extension"

  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']

  #before_create :rename_image_file
  #before_update :rename_image_file

  def rename_image_file
    extension = File.extname(photo_file_name).downcase
    self.photo.instance_write(:file_name, "#{User.current.profile.first_name}-#{Time.now.to_i}#{extension}")
  end

end
