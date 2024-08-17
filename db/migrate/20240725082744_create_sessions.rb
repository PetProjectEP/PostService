class CreateSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :sessions, id: false do |t|
      t.string :token,         null: false, index: { unique: true }
      t.references :user,      null: false, foreign_key: true
      t.timestamp :expires_at, null: false

      t.timestamps
    end
  end
end
