class AddFeedJoinTables < ActiveRecord::Migration
  def change
    create_table :newsfeed_activities do |t|
      t.belongs_to :user
      t.belongs_to :activity
    end
    add_index :newsfeed_activities, :user_id
    add_index :newsfeed_activities, :activity_id

    create_table :userfeed_activities do |t|
      t.belongs_to :user
      t.belongs_to :activity
    end
    add_index :userfeed_activities, :user_id
    add_index :userfeed_activities, :activity_id

    create_table :notification_activities do |t|
      t.belongs_to :user
      t.belongs_to :activity
    end
    add_index :notification_activities, :user_id
    add_index :notification_activities, :activity_id
  end
end
