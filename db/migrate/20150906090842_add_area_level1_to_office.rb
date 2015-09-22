class AddAreaLevel1ToOffice < ActiveRecord::Migration
  def change
    add_reference :offices, :area_level1, index: true, foreign_key: true
  end
end
