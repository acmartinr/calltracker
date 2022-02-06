class CreateDids < ActiveRecord::Migration[5.2]
  def change
    create_table :dids do |t|
      t.belongs_to :funnel, index: true
      t.string :number, index: true
      t.integer :calls_count, default: 0
      t.integer :sold_count, default: 0

      t.timestamps
    end
  end
end
