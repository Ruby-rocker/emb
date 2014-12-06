class UserValidator < ActiveModel::Validator

  def validate(record)
    # validate username format
    username_validator = UsernameValidator.new(record.username)
    unless username_validator.valid_format?
      username_validator.errors.each { |e| record.errors.add(:username, e) }
    end

    # validate username uniqueness
    unless record.errors[:username].any? || (record.respond_to?(:username_changed?) && !record.username_changed?)
      lower = record.username.downcase
      if User.where(username_lower: lower).exists?
        record.errors.add(:username, 'already taken')
      end
    end

    unless record.try(:skip_email_validation) || (record.respond_to?(:email_changed?) && !record.email_changed?)
      # validate email presence
      if !record.email.present?
        record.errors.add(:email, 'must be present')
      end

      # validate email uniqueness
      if record.email.present? && User.where(email_lower: record.email.downcase).exists?
        record.errors.add(:email, 'already taken')
      end
    end
  end

end
