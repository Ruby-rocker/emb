class ChangeIsPrivateFieldToIsPostPrivateToPostTable < ActiveRecord::Migration
  def up
  	rename_column :posts, :is_private, :is_post_private
  end

  def down
  end
end
