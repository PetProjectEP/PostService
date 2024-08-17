class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :nickname,        null: false, index: { unique: true }
      t.string :name,            null: false
      t.string :surname,         null: false
      t.string :password_digest, null: false
      t.text :about

      t.timestamps
    end
  end
end
