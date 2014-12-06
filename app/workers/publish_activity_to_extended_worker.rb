class PublishActivityToExtendedWorker
  include Sidekiq::Worker

  def perform(activity_id, options = {})
    activity = PublicActivity::Activity.find(activity_id)
    ActivityPublisher.new(activity).publish_to_extended(options)
  end

end
