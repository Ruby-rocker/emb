class MessageWithConversationSerializer < MessageSerializer

  self.root = :message

  has_one :conversation, embed: :ids, include: true

end
