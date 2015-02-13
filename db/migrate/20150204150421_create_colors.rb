class CreateColors < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      t.references :product, index: true
      t.text :name
      t.text :code
      t.text :hex_color_val
      t.text :state

      t.timestamps
    end
  end
end
