class AddAreaLevel2ToAreaLevel3 < ActiveRecord::Migration
  def change
    add_reference :area_level3s, :area_level2, index: true, foreign_key: true
  end
end
