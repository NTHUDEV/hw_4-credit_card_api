class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :fullname
      t.string :dob
      t.string :email
      t.string :address
      t.string :hashed_password
      t.string :salt
      t.string :nonce_data
      t.timestamps null: false
    end
  end
end
