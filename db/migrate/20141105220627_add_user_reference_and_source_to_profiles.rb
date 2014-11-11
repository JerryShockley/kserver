class AddUserReferenceAndSourceToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :source, :string
    add_column :profiles, :user_id, :integer
    add_index :profiles, :user_id
  end
end
