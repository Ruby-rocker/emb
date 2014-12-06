class TouchAllProfiles < ActiveRecord::Migration
  def up
    Profile.all.map(&:touch)
  end

  def down
  end
end
