# == Schema Information
#
# Table name: likes
#
#  id            :integer          not null, primary key
#  user_id       :integer          indexed
#  likeable_id   :integer          indexed => [likeable_type]
#  likeable_type :string(255)      indexed => [likeable_id]
#  emotion_cd    :integer          indexed
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Like < ActiveRecord::Base

  belongs_to :user
  belongs_to :likeable, polymorphic: true, counter_cache: :total_like_count

  as_enum :emotion, love: 1, happy: 2, sad: 3, laugh: 4, wow: 5, inspire: 6

  validates :emotion, as_enum: true
  validates :user_id, uniqueness: { scope: [:likeable_id, :likeable_type] }

  attr_accessible :emotion

  before_create :setup_like_counts
  after_create :increment_like_count
  after_update :update_like_count
  after_destroy :decrement_like_count

  def self.counts_for_likeable(likeable)
    counts = {}
    Like.emotions.each do |name, id|
      count = likeable.likes.where(emotion_cd: id).count
      counts[id] = count
    end
    counts
  end

  private

    def setup_like_counts
      if !likeable.like_counts
        counts = {}
        Like.emotions.each do |name, id|
          counts[id] = 0
        end
        likeable.like_counts = counts
      end
    end

    def increment_like_count
      likeable.like_counts[emotion_cd] += 1
      save_likeable_like_counts
    end

    def update_like_count
      if emotion_cd_changed?
        likeable.like_counts[emotion_cd_was] -= 1
        likeable.like_counts[emotion_cd] += 1
        save_likeable_like_counts
      end
    end

    def decrement_like_count
      likeable.like_counts[emotion_cd] -= 1
      save_likeable_like_counts
    end

    def save_likeable_like_counts
      like_counts = likeable.class.serialized_attributes['like_counts']
          .dump(likeable.like_counts)

      likeable.update_column :like_counts, like_counts
    end

end
