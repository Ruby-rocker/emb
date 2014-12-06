class ChangeIsPostPrivateToIsPrivate < ActiveRecord::Migration
  def change
    rename_column :posts, :is_post_private, :is_private
  end
end
