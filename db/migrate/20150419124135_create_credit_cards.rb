class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.text :encrypted_number
      t.text  :nonce
      t.string :owner
      t.string :expiration_date
      t.string :credit_network
    end
  end
end
