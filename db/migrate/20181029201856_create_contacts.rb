class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.belongs_to :campaign, index: :true
      t.string :lead_id, index: :true
      t.string :vendor_id
      t.string :phone_number
      t.string :group
      t.string :user
      t.string :term_reason
      t.integer :length_in_sec, default: 0

      t.timestamps
    end
  end
end
