class CreateLooks < ActiveRecord::Migration
  def change
    create_table :looks do |t|
      t.text :title
      t.text :short_desc
      t.text :desc
      t.text :usage_directions
      t.references :user, index: true
      t.boolean :active

      t.timestamps
    end
  end
end
