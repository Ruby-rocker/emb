class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :conversation
      t.references :user
      t.text :body
      t.timestamps
    end

    add_index :messages, :conversation_id
    add_index :messages, :user_id
  end
end
