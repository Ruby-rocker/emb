class CreateProfiles < ActiveRecord::Migration
  def change
    create_table(:profiles) do |t|
      t.references :user

      t.string  :first_name
      t.string  :last_name
      t.string  :gender
      t.text    :about_me
      t.string  :location
      t.string  :education
      t.string  :occupation
      t.date    :date_of_birth
      t.string  :avatar_url

      t.timestamps
    end

    add_index :profiles, :user_id
  end
end
