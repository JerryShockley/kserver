class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.text :filename
      t.references :user, index: true
      t.boolean :active
      t.integer :file_size
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end
