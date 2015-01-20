class CreateVideoUsages < ActiveRecord::Migration
  def change
    create_table :video_usages do |t|
      t.text :page
      t.text :role
      t.references :video, index: true

      t.timestamps
    end
  end
end
