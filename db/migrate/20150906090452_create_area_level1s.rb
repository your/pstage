class CreateAreaLevel1s < ActiveRecord::Migration
  def change
    create_table :area_level1s do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
