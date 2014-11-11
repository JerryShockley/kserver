class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :street1
      t.string :street2
      t.string :city
      t.string :state
      t.string :postal_code
      t.boolean :receive_emails, default: true

      t.timestamps
    end
    add_index :profiles, :email
  end
end
