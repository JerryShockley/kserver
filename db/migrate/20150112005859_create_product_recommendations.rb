class CreateProductRecommendations < ActiveRecord::Migration
  def change
    create_table :product_recommendations do |t|
      t.references :product_cluster, index: true, null: false
      t.references :product_app, index: true, null: false

      t.timestamps
    end
  end
end
