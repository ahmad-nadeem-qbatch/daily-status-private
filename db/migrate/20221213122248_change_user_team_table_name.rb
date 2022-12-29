class ChangeUserTeamTableName < ActiveRecord::Migration[7.0]
  def change
    rename_table :users_teams, :user_teams
  end
end
