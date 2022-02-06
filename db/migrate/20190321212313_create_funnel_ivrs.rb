class CreateFunnelIvrs < ActiveRecord::Migration[5.2]
  def change
    create_table :funnel_ivrs do |t|
      t.integer :funnel_id
      t.integer :ivr_id
      t.integer :rank
			t.string :options

      t.timestamps
    end
		
		add_index :funnel_ivrs, [:funnel_id, :ivr_id]
		remove_reference :ivrs, :funnel, index: true
		add_reference :ivrs, :user, index: true
  end
end
