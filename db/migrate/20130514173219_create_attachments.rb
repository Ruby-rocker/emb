class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string    :filepicker_url
      t.string    :s3_key
      t.string    :filename
      t.string    :mimetype
      t.integer   :filesize
      t.string    :media_type

      t.integer   :user_id
      t.integer   :attachable_id
      t.string    :attachable_type

      t.timestamps
    end

    add_index :attachments, :user_id
    add_index :attachments, [:attachable_id, :attachable_type]
  end
end
