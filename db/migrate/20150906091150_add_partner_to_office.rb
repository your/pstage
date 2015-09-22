class AddPartnerToOffice < ActiveRecord::Migration
  def change
    add_reference :offices, :partner, index: true, foreign_key: true
  end
end
