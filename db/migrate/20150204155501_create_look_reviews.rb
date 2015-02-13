class CreateLookReviews < ActiveRecord::Migration
  def change
    create_table :look_reviews do |t|
      t.text :title
      t.integer :rating
      t.boolean :recommended
      t.boolean :use_again
      t.text :review
      t.references :look, index: true
      t.references :user, index: true
      t.text :state

      t.timestamps
    end
  end
end
