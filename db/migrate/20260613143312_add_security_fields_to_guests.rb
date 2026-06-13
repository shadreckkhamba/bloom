class AddSecurityFieldsToGuests < ActiveRecord::Migration[8.1]
  def change
    add_column :guests, :verify_attempts, :integer
    add_column :guests, :verified_ip, :string
    add_column :guests, :verify_locked_until, :datetime
    add_column :guests, :flagged_shared, :boolean
  end
end
