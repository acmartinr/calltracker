class AddBillingReminderToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :send_billing_reminder, :boolean, default: true
  end
end
