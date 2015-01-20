class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.text :sku, unique: true, index: true,  null: false
      t.text :brand, index: true
      t.text :line, index: true
      t.text :name, index: true
      t.text :shade_name
      t.text :shade_code
      t.text :short_desc
      t.text :desc
      t.references :image_usage
      t.text :hex_color_val
      t.boolean :active, index: true
      t.integer :price_cents, null: false, default: 0 
      t.integer :cost_cents

      t.timestamps
    end
  end
end
