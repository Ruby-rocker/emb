class CommentLightSerializer < CommentSerializer

  self.root = :comment

  has_one :commentable, polymorphic: true, embed: :ids, include: false

end
