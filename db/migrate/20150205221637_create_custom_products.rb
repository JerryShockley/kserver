class CreateCustomProducts < ActiveRecord::Migration
  def change
    create_table :custom_products do |t|
      t.references :custom_product_set, index: true
      t.references :product_app, index: true

      t.timestamps
    end
  end
end
