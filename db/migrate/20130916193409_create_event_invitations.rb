class CreateEventInvitations < ActiveRecord::Migration
  def change
    create_table :event_invitations do |t|
      t.references :event
      t.references :user

      t.boolean :accepted, null: false, default: false
      t.datetime :acceptance_confirmed_at

      t.timestamps
    end
  end
end
