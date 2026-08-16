class AddTableNumberToGuests < ActiveRecord::Migration[8.1]
  def change
    add_column :guests, :table_number, :string
  end
end
