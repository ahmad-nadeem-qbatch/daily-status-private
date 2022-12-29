class RemoveUniqueIndexOnInvite < ActiveRecord::Migration[7.0]
  def change
    remove_index :invites, [:user_id, :team_id]
  end
end
