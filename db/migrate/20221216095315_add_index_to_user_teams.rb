class AddIndexToUserTeams < ActiveRecord::Migration[7.0]
  def change
    add_index :user_teams, [:user_id, :team_id]
  end
end
