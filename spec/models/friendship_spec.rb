# == Schema Information
#
# Table name: friendships
#
#  id          :integer          not null, primary key
#  sender_id   :integer          indexed => [receiver_id]
#  receiver_id :integer          indexed => [sender_id]
#  pending     :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe Friendship do

  it { should belong_to(:sender).class_name('User') }
  it { should belong_to(:receiver).class_name('User') }

  %w(sender receiver).each do |attr|
    it { should allow_mass_assignment_of attr }
  end

  context "basic validations" do
    it { should validate_presence_of :sender_id }
    it { should validate_presence_of :receiver_id }

    context "with db" do
      before do
        sender = Fabricate(:user)
        receiver = Fabricate(:user)
        Friendship.create!(sender: sender, receiver: receiver)
      end

      it { should validate_uniqueness_of(:receiver_id).scoped_to(:sender_id) }
    end
  end

  describe "creation" do
    context "with valid sender/receiver" do
      it "should be successful" do
        sender = Fabricate(:user)
        receiver = Fabricate(:user)
        Friendship.create(sender: sender, receiver: receiver).should be_persisted
      end
    end

    context "with same sender/receiver" do
      before do
        sender = Fabricate(:user)
        @friendship = Friendship.create(sender: sender, receiver: sender)
      end

      it "shouldn't save" do
        expect(@friendship).to_not be_persisted
      end

      it "should have error on base" do
        expect(@friendship.errors_on(:base)).to eq(["it's not possible to friend yourself"])
      end
    end

    context "when a connection already exists" do
      before do
        sender = Fabricate(:user)
        receiver = Fabricate(:user)
        Friendship.create(sender: sender, receiver: receiver)
        @friendship = Friendship.create(sender: receiver, receiver: sender)
      end

      it "shouldn't save" do
        expect(@friendship).to_not be_persisted
      end

      it "should have error on base" do
        expect(@friendship.errors_on(:base)).to eq(["you are already friends"])
      end
    end
  end

end
