class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.text :name
      t.integer :size
      t.column :duration, :interval
      t.text :filename
      t.text :dimensions
      t.references :user, index: true

      t.timestamps
    end
  end
end
