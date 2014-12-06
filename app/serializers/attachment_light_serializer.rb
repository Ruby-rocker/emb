class AttachmentLightSerializer < AttachmentSerializer

  self.root = :attachment

  has_one :attachable, polymorphic: true, embed: :ids, include: false

end
