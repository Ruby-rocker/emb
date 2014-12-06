class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.references :user

      t.string :title
      t.string :body
      t.datetime :start_time
      t.datetime :end_time
      t.string :location
      t.boolean :is_private, null: false, default: false

      t.timestamps
    end
  end
end
