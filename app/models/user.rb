class User < ApplicationRecord
  validates :password, presence: true
  has_one_attached :profile_picture
  has_and_belongs_to_many :teams, join_table: 'user_teams'
  rolify
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  def block_from_invitation?
    return invited_to_sign_up? if invitation_accepted_at.nil?

    false
  end
end
