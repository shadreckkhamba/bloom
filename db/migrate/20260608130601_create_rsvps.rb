class CreateRsvps < ActiveRecord::Migration[8.1]
  def change
    create_table :rsvps do |t|
      t.references :guest, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.boolean :bringing_spouse, default: false
      t.integer :seats_reserved, default: 1
      t.text :message
      t.boolean :checked_in, default: false, null: false

      t.timestamps
    end
  end
end
