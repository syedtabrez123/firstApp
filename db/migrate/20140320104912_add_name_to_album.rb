class AddNameToAlbum < ActiveRecord::Migration
  def change
    add_column :albums, :name, :string, :after => :user_id
  end
end
