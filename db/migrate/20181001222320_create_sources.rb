class CreateSources < ActiveRecord::Migration[5.2]
  def change
    create_table :sources do |t|
      t.belongs_to :user, index: true
      t.string :name
      t.integer :calls_count, default: 0
      t.integer :sold_count, default: 0

      t.timestamps
    end
  end
end
