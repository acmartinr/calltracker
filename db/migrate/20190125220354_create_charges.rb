class CreateCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :charges do |t|
      t.belongs_to :user, index: true
      t.integer :amount
      t.string :stripe_token

      t.timestamps
    end
  end
end
