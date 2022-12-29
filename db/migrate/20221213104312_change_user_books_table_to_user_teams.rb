class ChangeUserBooksTableToUserTeams < ActiveRecord::Migration[7.0]
  def change
    rename_table :user_books, :users_teams
  end
end
