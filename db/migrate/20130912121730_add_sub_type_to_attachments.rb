class AddSubTypeToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :sub_type, :string
    add_index :attachments, :sub_type
  end
end
