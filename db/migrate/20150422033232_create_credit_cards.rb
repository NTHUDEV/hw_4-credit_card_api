class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.string :encrypted_number
      t.string :expiration_date
      t.string :owner
      t.string :credit_network
      t.string :nonce
      t.timestamps null:false
    end
  end
end
