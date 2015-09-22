class AddPartnerToPartnership < ActiveRecord::Migration
  def change
    add_reference :partnerships, :partner, index: true, foreign_key: true
  end
end
