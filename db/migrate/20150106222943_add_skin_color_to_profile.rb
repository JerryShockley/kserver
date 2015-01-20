class AddSkinColorToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :skin_color, :string
    add_column :profiles, :eye_color, :string
    add_column :profiles, :hair_color, :string
    add_column :profiles, :age, :string
    add_column :profiles, :skin_type, :string
  end
end
