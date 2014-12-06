class AddExtraTextToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :extra_text, :string
  end
end
