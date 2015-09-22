class CreatePartners < ActiveRecord::Migration
  def change
    create_table :partners do |t|
      t.string :name
      t.string :note
      t.string :vat
      t.string :activities
      t.string :website
      t.string :logo
      t.string :active
      t.string :p_type

      t.timestamps null: false
    end
  end
end
