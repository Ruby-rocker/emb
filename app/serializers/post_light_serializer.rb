class PostLightSerializer < PostSerializer

  self.root = :post

  has_one :user
  has_many :attachments
  has_many :comments

end
