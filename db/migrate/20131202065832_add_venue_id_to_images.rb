class AddVenueIdToImages < ActiveRecord::Migration
  def change
    add_column :images, :venue_id, :integer, :after => :album_id
  end
end
