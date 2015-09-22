class AddAreaLevel1ToAreaLevel2 < ActiveRecord::Migration
  def change
    add_reference :area_level2s, :area_level1, index: true, foreign_key: true
  end
end
