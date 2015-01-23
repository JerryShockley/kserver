class CreateCustomLooks < ActiveRecord::Migration
  def change
    create_table :custom_looks do |t|
      t.references :product_set, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
