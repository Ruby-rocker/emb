class ChangeLikesEmotionToEmotionCd < ActiveRecord::Migration
  def up
    remove_index :likes, :emotion
    rename_column :likes, :emotion, :emotion_cd
    add_index :likes, :emotion_cd
  end

  def down
    remove_index :likes, :emotion_cd
    rename_column :likes, :emotion_cd, :emotion
    add_index :likes, :emotion_cd
  end
end
