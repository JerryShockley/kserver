class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.text :sku, unique: true, index: true,  null: false
      t.text :brand, index: true
      t.text :line, index: true
      t.text :name, index: true
      t.text :code
      t.text :short_desc
      t.text :desc
      t.text :size
      t.text :manufacturer_sku
      t.text :state, index: true
      t.float :avg_rating, precision: 2, scale: 1, null: false, default: 0.0
      t.integer :price_cents, null: false, default: 0 
      t.integer :cost_cents
      t.integer :product_reviews_count

      t.timestamps
    end
  end
end
