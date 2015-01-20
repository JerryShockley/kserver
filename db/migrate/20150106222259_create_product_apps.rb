class CreateProductApps < ActiveRecord::Migration
  def change
    create_table :product_apps do |t|
      t.integer :role, index: true, null: false
      t.references :product, index: true, null: false
      t.references :user, index: true
      t.integer :category, index: true, null: false

      t.timestamps
    end
  end
end
