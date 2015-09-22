class CreateAreaLevel2s < ActiveRecord::Migration
  def change
    create_table :area_level2s do |t|
      t.string :long_name
      t.string :short_name

      t.timestamps null: false
    end
  end
end
