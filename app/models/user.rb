class User < ApplicationRecord
  before_save { email.downcase! }
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i #正規表現を定数で定義する　大文字の変数はRubyでは定数になる
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }, #formatで正規表現「定数」を使いバリデーションする
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
end