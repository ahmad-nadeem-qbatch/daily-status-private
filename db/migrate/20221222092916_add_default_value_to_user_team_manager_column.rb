class AddDefaultValueToUserTeamManagerColumn < ActiveRecord::Migration[7.0]
  def change
    change_column_default :user_teams, :manager, false
  end
end
