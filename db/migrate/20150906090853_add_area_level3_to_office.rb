class AddAreaLevel3ToOffice < ActiveRecord::Migration
  def change
    add_reference :offices, :area_level3, index: true, foreign_key: true
  end
end
