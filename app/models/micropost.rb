class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  delegate :name, prefix: "user", to: :user

  POST_ATTRS = %i(content image).freeze

  validates :user_id, presence: true
  validates :content, presence: true,
            length: {maximum: Settings.micropost.content.max_length}
  validates :image, content_type: {in: Settings.micropost.image.content_types,
                                   message: I18n.t("microposts.image_invalid")},
                    size: {less_than: Settings.micropost.image.max_size
                                              .megabytes,
                           message: I18n.t("microposts.byte_invalid")}

  scope :newest, ->{order(created_at: :desc)}
  scope :post_by_user, ->(ids){where user_id: ids}

  def display_image
    image.variant resize_to_limit: [Settings.micropost.image.limit,
                                    Settings.micropost.image.limit]
  end
end
