class CreateProductReviews < ActiveRecord::Migration
  def change
    create_table :product_reviews do |t|
      t.text :title, null: false
      t.integer :rating, index: true
      t.boolean :recommended, index: true
      t.boolean :use_again, index: true
      t.text :review
      t.references :product, index: true
      t.references :user, index: true
      t.text :state, index: true

      t.timestamps
    end
  end
end
