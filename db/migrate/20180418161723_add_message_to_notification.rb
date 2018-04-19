class AddMessageToNotification < ActiveRecord::Migration[5.0]
  def change
    add_column :notifications, :message, :string
    add_column :notifications, :food_id, :integer
  end
end
