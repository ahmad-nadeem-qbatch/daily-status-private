class AddDefaultValueToStatusColumnInTeam < ActiveRecord::Migration[7.0]
  def change
    change_column_default :teams, :status, 'active'
  end
end
