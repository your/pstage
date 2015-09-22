class CreateOffices < ActiveRecord::Migration
  def change
    create_table :offices do |t|
      t.string :address
      t.string :additional
      t.float :latitude
      t.float :longitude
      t.string :tel
      t.string :fax

      t.timestamps null: false
    end
  end
end
