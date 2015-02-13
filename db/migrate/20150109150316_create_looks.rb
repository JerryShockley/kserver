class CreateLooks < ActiveRecord::Migration
  def change
    create_table :looks do |t|
      t.text :title
      t.text :code
      t.text :short_desc
      t.text :desc
      t.text :usage_directions
      t.float :avg_rating, precision: 2, scale: 1, null: false, default: 0.0
      
      t.references :user, index: true
      t.text :state
      t.integer :look_reviews_count
      

      t.timestamps
    end
  end
end
