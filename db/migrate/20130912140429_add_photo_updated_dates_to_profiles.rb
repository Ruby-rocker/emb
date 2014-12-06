class AddPhotoUpdatedDatesToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :photo_updated_at, :datetime
    add_column :profiles, :cover_photo_updated_at, :datetime
  end
end
