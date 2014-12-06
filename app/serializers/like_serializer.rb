class LikeSerializer < ApplicationSerializer

  attributes :id, :emotion, :created_at, :errors

  has_one :user
  has_one :likeable, polymorphic: true, embed: :ids, include: false

  def emotion
    object.emotion_cd
  end

end
