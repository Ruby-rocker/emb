class EndedFriendshipFeedCleanupWorker
  include Sidekiq::Worker

  def perform(sender_id, receiver_id)
    sender = User.find sender_id
    receiver = User.find receiver_id

    sender.newsfeed_activities.where(owner_id: receiver.id).each do |activity|
      receiver.newsfeed_activities.delete(activity)
    end

    receiver.newsfeed_activities.where(owner_id: sender.id).each do |activity|
      receiver.newsfeed_activities.delete(activity)
    end
  end
end
