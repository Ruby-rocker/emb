class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :user
      t.references :likeable, polymorphic: true
      t.integer :emotion, limit: 2
      t.timestamps
    end

    add_index :likes, :emotion
    add_index :likes, [:likeable_id, :likeable_type]
  end
end
