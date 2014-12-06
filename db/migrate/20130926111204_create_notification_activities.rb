class CreateNotificationActivities < ActiveRecord::Migration
  def change
    create_table :notification_activities do |t|
      t.belongs_to :user
      t.belongs_to :activity
      t.boolean :read, null: false, default: false
      t.boolean :clicked, null: false, default: false
      t.timestamps
    end
  end
end
