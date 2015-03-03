class CreateCustomProductSets < ActiveRecord::Migration
  def change
    create_table :custom_product_sets do |t|
      t.references :look, index: true, null: false
      t.text :skin_color, index: true, null:false
      t.references :user, index: true
      t.references :default_product_set, index: true

      t.timestamps
    end
  end
end
