class ChangeColumnNameProfilePicture < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :profile_picture, :image
  end
end
