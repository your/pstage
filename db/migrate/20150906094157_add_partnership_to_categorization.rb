class AddPartnershipToCategorization < ActiveRecord::Migration
  def change
    add_reference :categorizations, :partnership, index: true, foreign_key: true
  end
end
