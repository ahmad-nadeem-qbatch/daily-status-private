class CreateUserBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :user_books do |t|
      t.integer :user_id
      t.integer :team_id
      t.boolean :manager

      t.timestamps
    end
  end
end
