class Team < ApplicationRecord
  resourcify
  validates :name, presence: true
  has_and_belongs_to_many :users, join_table: 'user_teams'
end
