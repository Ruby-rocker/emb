class NewFriendshipFeedPopulatorWorker
  include Sidekiq::Worker

  def perform(friendship_id)
    friendship = Friendship.find(friendship_id)
    sender = friendship.sender
    receiver = friendship.receiver

    sender_activities = sender.activities_as_owner
    receiver_activities = receiver.activities_as_owner
    activities = sender_activities + receiver_activities

    publish_options = {
      exclude_notifications: true,
      exclude_userfeeds: true,
      send_emails: false
    }

    activities.each do |activity|
      ActivityPublisher.new(activity).publish_to_extended(publish_options)
    end
  end
end
