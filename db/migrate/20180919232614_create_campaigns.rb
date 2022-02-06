class CreateCampaigns < ActiveRecord::Migration[5.2]
  def change
    create_table :campaigns do |t|
      t.belongs_to :vertical, index: :true
      t.integer :contacts_count, default: 0
      t.integer :sold_count, default: 0
      t.integer :refund_count, default: 0
      t.integer :talk_average, default: 0
      t.string :name
      t.integer :campaign_type
      t.string :client_did
      t.datetime :schedule_start
      t.datetime :schedule_end
      t.string :blocked_states
      t.string :order_total
      t.string :daily_call_limit
      t.string :concurrent_call_limit
      t.string :buyer_balance
      t.string :buffer
      t.string :lead_cost
      t.string :vicidial_agent_user, index: :true
      t.boolean :vicidial_remote_agent, default: false
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
