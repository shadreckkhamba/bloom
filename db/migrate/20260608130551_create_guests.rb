class CreateGuests < ActiveRecord::Migration[8.1]
  def change
    create_table :guests do |t|
      t.references :wedding, null: false, foreign_key: true
      t.string :name
      t.string :phone
      t.string :token
      t.datetime :invitation_sent_at

      t.timestamps
    end
    add_index :guests, :token, unique: true
  end
end
