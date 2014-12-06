class UpdateExistingActivitiesUserfeedPostedAtDates < ActiveRecord::Migration
  def up
    PublicActivity::Activity.where(key: 'post.create').each do |activity|
      activity.update_column :userfeed_posted_at, activity.trackable.posted_at
    end

    PublicActivity::Activity.where(key: 'event.create').each do |activity|
      activity.update_column :userfeed_posted_at, activity.posted_at
    end
  end

  def down
  end
end
