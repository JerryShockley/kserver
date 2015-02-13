class CreateCustomProductSets < ActiveRecord::Migration
  def change
    create_table :custom_product_sets do |t|
      t.references :product_set, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
