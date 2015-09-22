class AddOfficeToPartnership < ActiveRecord::Migration
  def change
    add_reference :partnerships, :office, index: true, foreign_key: true
  end
end
