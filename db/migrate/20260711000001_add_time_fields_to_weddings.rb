class AddTimeFieldsToWeddings < ActiveRecord::Migration[8.1]
  def change
    add_column :weddings, :church_time, :string
    add_column :weddings, :dinner_time, :string
  end
end
