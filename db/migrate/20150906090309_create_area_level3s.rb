class CreateAreaLevel3s < ActiveRecord::Migration
  def change
    create_table :area_level3s do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
