class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.boolean :buyer, default: false
      t.string :password_digest
      t.string :remember_digest
      t.boolean :email_confirmed, default: false
      t.string :confirm_token
      t.datetime :password_reset_sent_at
      t.string :password_reset_token
      t.decimal :balance, precision: 11, scale: 4, default: 0
      t.decimal :billing_rate, precision: 11, scale: 4
      t.integer :master_user_id, index: true
      t.integer :buyer_campaign_id, index: true
      

      t.timestamps
    end
  end
end
