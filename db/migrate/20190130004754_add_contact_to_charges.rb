class AddContactToCharges < ActiveRecord::Migration[5.2]
  def change
    add_reference :charges, :contact, index: true
    change_column :charges, :amount, :decimal, precision: 11, scale: 4
  end
end
