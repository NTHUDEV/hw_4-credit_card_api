class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :user_password
      t.string :salt
      t.string :email
      t.string :full_name
      t.string :nonce_full_name
      t.string :address
      t.string :nonce_address
      t.string :dob
      t.string :nonce_dob
      t.timestamps null: false
    end
  end
end
