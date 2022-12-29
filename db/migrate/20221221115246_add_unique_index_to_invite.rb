class AddUniqueIndexToInvite < ActiveRecord::Migration[7.0]
  def change
    add_index :invites, [:user_id, :team_id], unique: true
  end
end
