class AddIndexToPostedAtOnActivities < ActiveRecord::Migration
  def change
    add_index :activities, :posted_at
  end
end
