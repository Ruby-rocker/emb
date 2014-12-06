require 'spec_helper'

# Friendships concern is only included in User so lets test that

describe User do
  context "class methods" do
    # sent friendship requests
    it { should have_many(:sent_friendships).
                    class_name('Friendship').
                    dependent(:destroy) }

    # pending sent friendship requests
    it { should have_many(:pending_sent_friendships).
                    through(:sent_friendships).
                    conditions(:'friendships.pending' => true) }

    # accepted sent friendship requests
    it { should have_many(:accepted_sent_friendships).
                    through(:sent_friendships).
                    conditions(:'friendships.pending' => false) }

    # received friendship requests
    it { should have_many(:received_friendships).
                    class_name('Friendship').
                    dependent(:destroy) }

    # pending received friendship requests
    it { should have_many(:pending_received_friendships).
                    through(:received_friendships).
                    conditions(:'friendships.pending' => true) }

    # accepted received friendship requests
    it { should have_many(:accepted_received_friendships).
                    through(:received_friendships).
                    conditions(:'friendships.pending' => false) }

  end

  describe "#send_friendship_request_to" do
    let(:sender)    { Fabricate(:user) }
    let(:receiver)  { Fabricate(:user) }

    it "should create friendship for valid request" do
      friendship = sender.send_friendship_request_to(receiver)
      friendship.should be_persisted
    end

    it "should not create friendship for invalid request" do
      friendship = sender.send_friendship_request_to(sender)
      friendship.should_not be_persisted
    end
  end

  describe "#approve_friendship_with" do
    it "should return true on success" do
      sender = Fabricate(:user)
      receiver = Fabricate(:user)
      sender.send_friendship_request_to(receiver)
      receiver.approve_friendship_with(sender).should be_true
    end

    it "should return false when friendship doesn't exist" do
      user = Fabricate(:user)
      user.approve_friendship_with(Fabricate(:user)).should be_false
    end

    it "should return false when self was the sender" do
      sender = Fabricate(:user)
      receiver = Fabricate(:user)
      sender.send_friendship_request_to(receiver)
      sender.approve_friendship_with(receiver).should be_false
    end
  end

  describe "#remove_friendship_with_user" do
    it "should return true on success" do
      sender = Fabricate(:user)
      receiver = Fabricate(:user)
      sender.send_friendship_request_to(receiver)
      receiver.remove_friendship_with(sender).should be_true
    end

    it "should return false when friendship doesn't exist" do
      user = Fabricate(:user)
      user.remove_friendship_with(Fabricate(:user)).should be_false
    end
  end

  describe "#friends" do
    context "with approved friendships" do
      before do
        @sender = Fabricate(:user)
        @receiver = Fabricate(:user)
        friendship = @sender.send_friendship_request_to(@receiver)
        @receiver.approve_friendship_with(@sender)
      end

      it "should list sent requests" do
        @sender.friends.should include @receiver
      end

      it "should list received requests" do
        @receiver.friends.should include @sender
      end
    end

    it "should not list pending requests" do
      sender = Fabricate(:user)
      receiver = Fabricate(:user)
      sender.send_friendship_request_to(receiver)
      sender.friends.should be_empty
    end
  end

  describe "#total_friends_count" do
    before do
      @sender = Fabricate(:user)
      @receiver = Fabricate(:user)
      Friendship.create(sender: @sender, receiver: @receiver)
    end

    it "should include approved friendships" do
      @receiver.approve_friendship_with(@sender)
      @receiver.total_friends_count.should eq(1)
    end

    it "should not include pending friendships" do
      @receiver.total_friends_count.should eq(0)
    end

    it "should count both received and sent friendships" do
      @receiver.approve_friendship_with(@sender)
      @receiver.total_friends_count.should eq(1)
      @sender.total_friends_count.should eq(1)
    end
  end

  describe "#friends_with?" do
    before do
      @sender = Fabricate(:user)
      @receiver = Fabricate(:user)
    end

    it "should return true for approved friendships" do
      Friendship.create(sender: @sender, receiver: @receiver)
      @receiver.approve_friendship_with(@sender)
      @receiver.friends_with?(@sender).should be_true
      @sender.friends_with?(@receiver).should be_true
    end

    it "should return false for pending friendship" do
      Friendship.create(sender: @sender, receiver: @receiver)
      @receiver.friends_with?(@sender).should be_false
      @sender.friends_with?(@receiver).should be_false
    end

    it "should return false for no friendship" do
      @receiver.friends_with?(@sender).should be_false
      @sender.friends_with?(@receiver).should be_false
    end
  end

  describe "#connected_with?" do
    before do
      @sender = Fabricate(:user)
      @receiver = Fabricate(:user)
    end

    it "should return true for approved friendships" do
      Friendship.create(sender: @sender, receiver: @receiver)
      @receiver.approve_friendship_with(@sender)
      @receiver.connected_with?(@sender).should be_true
      @sender.connected_with?(@receiver).should be_true
    end

    it "should return true for pending friendships" do
      Friendship.create(sender: @sender, receiver: @receiver)
      @receiver.connected_with?(@sender).should be_true
      @sender.connected_with?(@receiver).should be_true
    end

    it "should return false for no friendship" do
      @receiver.connected_with?(@sender).should be_false
      @sender.connected_with?(@receiver).should be_false
    end
  end

  describe "#received_friendship_from?" do
    before do
      @sender = Fabricate(:user)
      @receiver = Fabricate(:user)
    end

    context "with approved friendship" do
      before do
        Friendship.create(sender: @sender, receiver: @receiver)
        @receiver.approve_friendship_with(@sender)
      end

      it "should return true for received friendship" do
        @receiver.received_friendship_from?(@sender).should be_true
      end

      it "should return false for sent friendship" do
        @sender.received_friendship_from?(@receiver).should be_false
      end
    end

    context "with pending friendship" do
      before do
        Friendship.create(sender: @sender, receiver: @receiver)
      end

      it "should return true for received friendship" do
        @receiver.received_friendship_from?(@sender).should be_true
      end

      it "should return false for sent friendship" do
        @sender.received_friendship_from?(@receiver).should be_false
      end
    end

    it "should return false for no friendship" do
      @receiver.received_friendship_from?(@sender).should be_false
    end
  end

  describe "#sent_friendship_to?" do
    before do
      @sender = Fabricate(:user)
      @receiver = Fabricate(:user)
    end

    context "with approved friendship" do
      before do
        Friendship.create(sender: @sender, receiver: @receiver)
        @receiver.approve_friendship_with(@sender)
      end

      it "should return true for sent friendship" do
        @sender.sent_friendship_to?(@receiver).should be_true
      end

      it "should return false for received friendship" do
        @receiver.sent_friendship_to?(@sender).should be_false
      end
    end

    context "with pending friendship" do
      before do
        Friendship.create(sender: @sender, receiver: @receiver)
      end

      it "should return true for received friendship" do
        @sender.sent_friendship_to?(@receiver).should be_true
      end

      it "should return false for sent friendship" do
        @receiver.sent_friendship_to?(@sender).should be_false
      end
    end

    it "should return false for no friendship" do
      @sender.sent_friendship_to?(@receiver).should be_false
    end
  end

  describe "#common_friends_with" do
    before do
      @common_friend  = Fabricate(:user)
      @first_friend   = Fabricate(:user)
      @second_friend  = Fabricate(:user)

      @first_friend.send_friendship_request_to(@common_friend)
      @second_friend.send_friendship_request_to(@common_friend)
    end

    context "with approved friendships" do
      before do
        @common_friend.approve_friendship_with(@first_friend)
        @common_friend.approve_friendship_with(@second_friend)
      end

      it "should return common friends" do
        @first_friend.common_friends_with(@second_friend).should include @common_friend
      end

      it "should not return non-common friends" do
        @third_friend = Fabricate(:user)
        @second_friend.send_friendship_request_to(@third_friend)
        @third_friend.approve_friendship_with(@second_friend)

        @first_friend.common_friends_with(@second_friend).should_not include @third_friend
      end
    end

    it "should ignore pending friendships" do
      @first_friend.common_friends_with(@second_friend).should be_empty
    end
  end

end
