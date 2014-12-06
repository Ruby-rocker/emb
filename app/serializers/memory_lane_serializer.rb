class MemoryLaneSerializer < ApplicationSerializer

  attributes :id, :date, :posts_count, :events_count

  has_one :user
  has_one :profile_version, embed: :ids, include: true
  has_many :activities, embed: :ids, include: true, serializer: ActivitySerializer, root: 'userfeed_activities'

end
