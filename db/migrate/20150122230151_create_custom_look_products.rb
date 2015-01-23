class CreateCustomLookProducts < ActiveRecord::Migration
  def change
    create_table :custom_look_products do |t|
      t.references :custom_look, index: true
      t.references :product_app, index: true

      t.timestamps
    end
  end
end
