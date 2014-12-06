# == Schema Information
#
# Table name: profile_versions
#
#  id         :integer          not null, primary key
#  item_type  :string(255)      not null, indexed => [item_id]
#  item_id    :integer          not null, indexed => [item_type]
#  event      :string(255)      not null
#  whodunnit  :string(255)
#  object     :text
#  created_at :datetime
#

class ProfileVersion < PaperTrail::Version
  self.table_name = :profile_versions
  self.sequence_name = :profile_versions_id_s
end
