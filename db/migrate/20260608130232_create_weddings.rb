class CreateWeddings < ActiveRecord::Migration[8.1]
  def change
    create_table :weddings do |t|
      t.string :bride_name
      t.string :groom_name
      t.date :wedding_date
      t.string :venue
      t.string :theme
      t.text :welcome_message
      t.string :couple_photo

      t.timestamps
    end
  end
end
