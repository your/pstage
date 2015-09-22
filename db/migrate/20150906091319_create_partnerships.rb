class CreatePartnerships < ActiveRecord::Migration
  def change
    create_table :partnerships do |t|
      t.datetime :signing_date
      t.boolean :active

      t.timestamps null: false
    end
  end
end
