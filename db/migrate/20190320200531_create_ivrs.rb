class CreateIvrs < ActiveRecord::Migration[5.2]
  def change
    create_table :ivrs do |t|
      t.belongs_to :funnel, index: true
      t.string :name
			t.string :recording_file
			t.string :options
			t.string :vici_callmenu
      t.integer :funnel_count

      t.timestamps
    end
  end
end
