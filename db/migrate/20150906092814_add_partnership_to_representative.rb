class AddPartnershipToRepresentative < ActiveRecord::Migration
  def change
    add_reference :representatives, :partnership, index: true, foreign_key: true
  end
end
