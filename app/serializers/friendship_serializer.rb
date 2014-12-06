class FriendshipSerializer < ApplicationSerializer

  attributes :id, :pending, :errors

  has_one :sender, class_name: 'User', embed: :ids, include: true, root: 'users'
  has_one :receiver, class_name: 'User', embed: :ids, include: true, root: 'users'

end
