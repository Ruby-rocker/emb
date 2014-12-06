class AddEmailOnTagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_on_tag, :boolean, null: false, default: true
  end
end
