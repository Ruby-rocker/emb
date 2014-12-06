class ActivitySerializer < ApplicationSerializer

  attributes :id,
      :key,
      :parameters,
      :owner_id,
      :trackable_type,
      :trackable_id,
      :trackable_privacy,
      :posted_at,
      :userfeed_posted_at,
      :created_at,
      :updated_at,
      :read,
      :clicked

  has_one :trackable, polymorphic: true, embed: :ids, include: true
  has_one :owner, polymorphic: true

  def include_read?
    object.respond_to?(:read) || (object.status_attrs && object.status_attrs.has_key?(:read))
  end

  def trackable_privacy
    trackable.respond_to?(:is_private?) && trackable.is_private? || false
  end

  def read
    if object.respond_to?(:read)
      object.read == 't' ? true : false
    else
      object.status_attrs[:read]
    end
  end

  def include_clicked?
    object.respond_to?(:clicked) || (object.status_attrs && object.status_attrs.has_key?(:clicked))
  end

  def clicked
    if object.respond_to?(:clicked)
      object.clicked == 't' ? true : false
    else
      object.status_attrs[:clicked]
    end
  end

end
