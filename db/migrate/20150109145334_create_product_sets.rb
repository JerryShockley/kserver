class CreateProductSets < ActiveRecord::Migration
  def change
    create_table :product_sets do |t|
      t.references :look, index: true, null: false
      t.text :skin_color, index: true, null:false
      t.references :user, index: true

      t.timestamps
    end
  end
end
