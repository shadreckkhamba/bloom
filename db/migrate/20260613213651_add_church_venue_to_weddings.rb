class AddChurchVenueToWeddings < ActiveRecord::Migration[8.1]
  def change
    add_column :weddings, :church_venue, :string
  end
end
