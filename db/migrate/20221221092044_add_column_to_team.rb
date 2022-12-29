class AddColumnToTeam < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :status, :string
  end
end
