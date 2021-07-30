class User < ApplicationRecord
  before_save :downcase_email

  validates :name, presence: true,
            length: {maximum: Settings.validate.name.max_length}
  validates :email, presence: true,
            length: {maximum: Settings.validate.email.max_length},
            format: {with: Settings.validate.email.format},
            uniqueness: {case_sensitive: false}
  validates :password, presence: true,
            length: {minimum: Settings.validate.password.min_length}

  has_secure_password

  private
  def downcase_email
    email.downcase!
  end
end
