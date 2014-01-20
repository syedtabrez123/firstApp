class AddNameToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :first_name, :string, :after => :user_id
    add_column :profiles, :last_name, :string, :after => :first_name
  end
end
