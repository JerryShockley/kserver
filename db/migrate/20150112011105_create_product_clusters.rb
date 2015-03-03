class CreateProductClusters < ActiveRecord::Migration
  def change
    create_table :product_clusters do |t|
      t.text :category, index: true, null: false 
      t.text :role, index: true, null: false
      t.string :subrole
      t.references :user, index: true
      t.references :product_set, index: true, null: false
      
      t.timestamps
    end    
  end
end
