class AddPartnerToWeddings < ActiveRecord::Migration[8.1]
  def change
    add_column :weddings, :partner_id, :integer
    add_column :weddings, :seat_limit, :integer
    add_column :weddings, :partner_invite_token, :string

    add_index :weddings, :partner_id
    add_index :weddings, :partner_invite_token, unique: true

    add_foreign_key :weddings, :users, column: :partner_id
  end
end
