class CreateProductClusters < ActiveRecord::Migration
  def change
    create_table :product_clusters do |t|
      t.text :category, index: true, null: false 
      t.text :role, index: true, null: false
      t.references :user, index: true
      t.references :product_set, index: true, null: false
      
      t.timestamps
    end    
    add_index(:product_clusters, [:product_set_id, :category, :role], unique: true)
  end
end
