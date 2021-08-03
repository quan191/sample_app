class User < ApplicationRecord
  attr_accessor :remember_token

  before_save :downcase_email

  PERMITTED_FIELDS = [:name, :email, :password, :password_confirmation].freeze

  validates :name, presence: true,
            length: {maximum: Settings.validate.name.max_length}
  validates :email, presence: true,
            length: {maximum: Settings.validate.email.max_length},
            format: {with: Settings.validate.email.format},
            uniqueness: {case_sensitive: false}
  validates :password, presence: true,
            length: {minimum: Settings.validate.password.min_length}

  has_secure_password

  class << self
    def digest string
      check = ActiveModel::SecurePassword.min_cost
      cost = check ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  private
  def downcase_email
    email.downcase!
  end
end
