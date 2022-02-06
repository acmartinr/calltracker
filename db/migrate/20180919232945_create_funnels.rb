class CreateFunnels < ActiveRecord::Migration[5.2]
  def change
    create_table :funnels do |t|
      t.belongs_to :user, index: :true
      t.belongs_to :vertical, index: :true
      t.string :name
      t.string :forwarding_number
      t.integer :routing_type
      t.boolean :mask_number, default: false
      t.boolean :active, default: true
      t.string :vicidial_ingroup_id

      t.timestamps
    end
  end
end
