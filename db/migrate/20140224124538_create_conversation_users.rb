class CreateConversationUsers < ActiveRecord::Migration
  def change
    create_table :conversation_users do |t|
      t.references :conversation
      t.references :user
      t.timestamps
    end

    add_index :conversation_users, :conversation_id
    add_index :conversation_users, :user_id
  end
end
