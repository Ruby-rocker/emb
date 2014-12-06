class AddClickedToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :clicked, :boolean
  end
end
