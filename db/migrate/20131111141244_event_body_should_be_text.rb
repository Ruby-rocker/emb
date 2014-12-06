class EventBodyShouldBeText < ActiveRecord::Migration
  def change
    change_column :events, :body, :text
  end
end
