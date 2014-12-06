class AddUserfeedPostedAtToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :userfeed_posted_at, :datetime
    add_index :activities, :userfeed_posted_at
  end
end
