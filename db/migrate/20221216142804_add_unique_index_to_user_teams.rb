class AddUniqueIndexToUserTeams < ActiveRecord::Migration[7.0]
  def change
    remove_index :user_teams, [[:user_id, :team_id]]
    add_index :user_teams, [:user_id, :team_id], unique: true
  end
end
