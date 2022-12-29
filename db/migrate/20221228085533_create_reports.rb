class CreateReports < ActiveRecord::Migration[7.0]
  def change
    create_table :reports do |t|
      t.references :team, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :date
      t.string :title
      t.string :task_link
      t.string :time_spent
      t.string :time_remaining
      t.string :status
      t.string :blockers

      t.timestamps
    end
  end
end
