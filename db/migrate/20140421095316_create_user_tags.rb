class CreateUserTags < ActiveRecord::Migration
  def change
    create_table :user_tags do |t|
      t.references :post
      t.references :user
      t.timestamps
    end

    add_index :user_tags, :post_id
    add_index :user_tags, :user_id
  end
end
