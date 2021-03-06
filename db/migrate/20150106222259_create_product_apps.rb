class CreateProductApps < ActiveRecord::Migration
  def change
    create_table :product_apps do |t|
      t.string :role, index: true, null: false
      t.string :subrole
      t.references :product, index: true, null: false
      t.references :user, index: true
      t.references :color, index: true
      t.string :category, index: true, null: false

      t.timestamps
    end
  end
end
