class ApplicationSerializer < ActiveModel::Serializer

  # sideload related data by default
  embed :ids, include: false

end
