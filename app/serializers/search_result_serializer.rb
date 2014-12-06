class SearchResultSerializer < ApplicationSerializer

  attributes :id

  has_many :users, embed: :ids, include: true
  has_many :posts
  has_many :media_posts
  has_many :events

end
