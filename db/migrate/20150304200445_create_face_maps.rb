class CreateFaceMaps < ActiveRecord::Migration
  def change
    create_table :face_maps do |t|
      t.references :look, index: true
      t.references :image, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
