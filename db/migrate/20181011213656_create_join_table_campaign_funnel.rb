class CreateJoinTableCampaignFunnel < ActiveRecord::Migration[5.2]
  def change
    create_join_table :campaigns, :funnels do |t|
      t.index [:campaign_id, :funnel_id]
      # t.index [:funnel_id, :campaign_id]
    end
  end
end
