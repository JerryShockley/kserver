class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.text :name
      t.text :filename
      t.text :dir
      t.text :page
      t.text :template
      t.text :group
      t.text :model
      t.text :role
      t.text :description
      t.text :storage_site
      t.text :code
      t.integer :size
      t.time :duration
      t.text :url
      t.text :file_type
      t.references :user, index: true
      t.text :status
      t.references :videoable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
