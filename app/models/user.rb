class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

  paginates_per Settings.record_per_page

  before_save :downcase_email
  before_create :create_activation_digest

  PERMITTED_FIELDS = [:name, :email, :password, :password_confirmation].freeze

  PASSWORD_ATTRS = %i(password password_confirmation).freeze

  validates :name, presence: true,
            length: {maximum: Settings.validate.name.max_length}
  validates :email, presence: true,
            length: {maximum: Settings.validate.email.max_length},
            format: {with: Settings.validate.email.format},
            uniqueness: {case_sensitive: false}
  validates :password, presence: true,
            length: {minimum: Settings.validate.password.min_length},
            allow_nil: true

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

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.expired_time.hours.ago
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  private
  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
