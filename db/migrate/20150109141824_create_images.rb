class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.text :name
      t.text :filename
      t.text :dir
      t.text :page
      t.text :template
      t.text :group
      t.text :model
      t.text :role
      t.text :description
      t.text :dir
      t.text :file_type
      t.text :code
      t.references :user, index: true
      t.text :state, "active"
      t.integer :file_size
      t.integer :width
      t.integer :height
      t.references :imageable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
