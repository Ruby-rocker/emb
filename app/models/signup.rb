class Signup
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::SerializerSupport

  attr_reader :user
  attr_reader :profile

  attribute :email, String
  attribute :username, String
  attribute :password, String
  attribute :first_name, String
  attribute :last_name, String

  attribute :gender, String
  attribute :birthday, Date
  attribute :about_me, String
  attribute :location, String
  attribute :education, String
  attribute :occupation, String
  attribute :image_url, String

  attribute :oauth_provider, String
  attribute :oauth_uid, String
  attribute :oauth_token, String
  attribute :oauth_secret, String

  attribute :skip_confirmation, Boolean, default: false
  attribute :skip_email_validation, Boolean, default: false

  validates :email, presence: true, unless: :skip_email_validation
  validates :password, presence: true, unless: :has_valid_oauth?
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates_with UserValidator

  def name=(name)
    self.first_name, self.last_name = name.split(' ', 2)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def generate_username
    # TODO: check for username uniqueness and add number until valid
    max_username_length = User.username_length.end
    full_name.parameterize('_')[0..max_username_length-1]
  end

  def gender=(gender)
    @gender = gender.downcase.titleize
  end

  # Forms are never themselves persisted
  def persisted?
    false
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  def skip_confirmation!
    self.skip_confirmation = true
  end

  def skip_confirmation?
    skip_confirmation || has_valid_oauth?
  end

  def skip_email_validation!
    self.skip_email_validation = true
  end

  def has_valid_oauth?
    oauth_provider.present? && oauth_uid.present? && oauth_token.present?
  end

  private

    def persist!
      User.transaction do
        @user = User.new(email: email, username: username, password: password)

        @user.skip_confirmation! if skip_confirmation?
        @user.skip_email_validation = true if skip_email_validation

        if !password.present? && has_valid_oauth?
          @user.password = Devise.friendly_token[0,10]
        end

        @user.save!

        @profile = @user.create_profile!(
          first_name: first_name,
          last_name: last_name,
          gender: gender,
          date_of_birth: birthday,
          about_me: about_me,
          location: location,
          education: education,
          occupation: occupation
        )

        if image_url
          attachment = Attachment.new_from_url(image_url)
          attachment.user = @user
          attachment.attachable = @profile
          attachment.save!
        end

        if has_valid_oauth?
          authentication = @user.authentications.create!(
            provider: oauth_provider,
            uid: oauth_uid,
            token: oauth_token,
            token_secret: oauth_secret
          )
        end
      end
    end
end
