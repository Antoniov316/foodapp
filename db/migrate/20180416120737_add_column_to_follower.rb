class AddColumnToFollower < ActiveRecord::Migration[5.0]
  def change
    add_column :followers, :user_id, :integer
    add_column :followers, :follower_id, :integer
    add_column :followers, :status, :boolean, :default=> false
  end
end
