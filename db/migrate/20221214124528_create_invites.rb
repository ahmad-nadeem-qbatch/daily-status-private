class CreateInvites < ActiveRecord::Migration[7.0]
  def change
    create_table :invites do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.string :invitation_token
      t.string :invitation_created_at
      t.string :invitation_sent_at
      t.string :invitation_accepted_at

      t.timestamps
    end
  end
end
