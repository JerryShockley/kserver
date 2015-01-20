class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.text :first_name
      t.text :last_name
      t.text :email
      t.text :street1
      t.text :street2
      t.text :city
      t.text :state
      t.text :postal_code
      t.boolean :receive_emails, default: true

      t.timestamps
    end
    add_index :profiles, :email, unique: true
  end
end
