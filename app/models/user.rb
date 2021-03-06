class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :articles
  has_many :comments
  #フォローのみを考える
  has_many :following_relationships, foreign_key: "follower_id", class_name: "Relationship", dependent: :destroy
  #フォローしているユーザーを特定
  has_many :followings, through: :following_relationships
  #フォローされることを考える
  has_many :follower_relationships, foreign_key: "following_id", class_name: "Relationship", dependent: :destroy
  #フォローされているユーザーを特定
  has_many :followers, through: :follower_relationships

  #現在のユーザーがフォーローしているかどうか
  def following?(other_user)
    following_relationships.find_by(following_id: other_user.id)
  end

  #フォローをする
  def follow!(other_user)
    following_relationships.create!(following_id: other_user.id)
  end

  #フォローを外す
  def unfollow!(other_user)
    following_relationships.find_by(following_id: other_user.id).destroy
  end

  validates :nickname, presence: true, length: {maximum: 6}
  has_one_attached :avatar

  def self.search(search)
    if search
      where(['nickname LIKE ?', "%#{search}%"])
    else
      all
    end
  end
end
