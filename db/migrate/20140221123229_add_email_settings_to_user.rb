class AddEmailSettingsToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_on_friend_request, :boolean, null: false, default: true
    add_column :users, :email_on_comment, :boolean, null: false, default: true
    add_column :users, :email_on_like, :boolean, null: false, default: true
    add_column :users, :email_on_event_invite, :boolean, null: false, default: true
    add_column :users, :email_on_event_post, :boolean, null: false, default: true
    add_column :users, :email_on_message, :boolean, null: false, default: true
    add_column :users, :email_on_mention, :boolean, null: false, default: true
  end
end
