class UsernameValidator

  def initialize(username)
    @username = username
    @errors = []
  end
  attr_accessor :errors
  attr_reader :username

  def valid_format?
    username_exist?
    username_length_min?
    username_length_max?
    username_char_valid?
    username_first_char_valid?
    errors.empty?
  end

  private

    def username_exist?
      return unless errors.empty?
      unless username
        self.errors << "can't be blank"
      end
    end

    def username_length_min?
      return unless errors.empty?
      if username.length < User.username_length.begin
        self.errors << "must be longer than #{User.username_length.begin} characters"
      end
    end

    def username_length_max?
      return unless errors.empty?
      if username.length > User.username_length.end
        self.errors << "must be shorter than #{User.username_length.end} characters"
      end
    end

    def username_char_valid?
      return unless errors.empty?
      if username =~ /[^a-z0-9_]/i
        self.errors << "must include only letters and numbers"
      end
      if username =~ /^[0-9]+$/
        self.errors << "can't be a number"
      end
    end

    def username_first_char_valid?
      return unless errors.empty?
      if username[0,1] =~ /[^a-z0-9]/i
        self.errors << "must begin with a letter or number"
      end
    end

end
