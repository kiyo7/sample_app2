class Micropost < ApplicationRecord
  belongs_to       :user
  has_one_attached :image
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "無効な画像形式です" },
                      size:         { less_than: 5.megabytes,
                                      message: "5MB以下である必要があります" }
                                      
  #表示用のリサイズ済み画像を返す
  def display_image
    image.variant(resize_to_limit: [500,500]) #投稿される画像のサイズに制約をかける
  end
end