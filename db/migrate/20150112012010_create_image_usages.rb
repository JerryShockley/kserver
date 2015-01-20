class CreateImageUsages < ActiveRecord::Migration
  def change
    create_table :image_usages do |t|
      t.text :page
      t.text :role
      t.references :image, index: true

      t.timestamps
    end
  end
end
