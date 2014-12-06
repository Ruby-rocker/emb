class AddUsersCountToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :users_count, :integer, null: false, default: 0
    add_index :conversations, :users_count
  end
end
