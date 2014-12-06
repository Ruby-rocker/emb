class StorePhotoIdsOnProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :photo_id, :integer
    add_column :profiles, :cover_photo_id, :integer
    remove_column :profiles, :photo_updated_at
    remove_column :profiles, :cover_photo_updated_at
  end
end
