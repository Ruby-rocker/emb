class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :receiver
      t.references :instigator
      t.references :notifiable, polymorphic: true
      t.string :action
      t.boolean :read, null: false, default: false

      t.timestamps
    end

    add_index :notifications, :receiver_id
    add_index :notifications, :read
    add_index :notifications, [:notifiable_id, :notifiable_type]
  end
end
