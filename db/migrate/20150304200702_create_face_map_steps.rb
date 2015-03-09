class CreateFaceMapSteps < ActiveRecord::Migration
  def change
    create_table :face_map_steps do |t|
      t.integer :number
      t.text :description
      t.references :face_map, index: true

      t.timestamps
    end
  end
end
