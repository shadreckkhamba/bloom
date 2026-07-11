class AddAddedByToGuests < ActiveRecord::Migration[8.1]
  def change
    add_column :guests, :added_by_id, :integer
    add_index  :guests, :added_by_id
    add_foreign_key :guests, :users, column: :added_by_id

    # Backfill: attribute existing guests to the wedding owner
    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE guests
          SET added_by_id = (
            SELECT user_id FROM weddings WHERE weddings.id = guests.wedding_id
          )
          WHERE added_by_id IS NULL
        SQL
      end
    end
  end
end
