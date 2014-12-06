class DropNotificationActivitiesTable < ActiveRecord::Migration
  def up
    drop_table :notification_activities
  end

  def down
    create_table :notification_activities do |t|
      t.belongs_to :user
      t.belongs_to :activity
    end
    add_index :notification_activities, :user_id
    add_index :notification_activities, :activity_id
  end
end
