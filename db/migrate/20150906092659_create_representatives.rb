class CreateRepresentatives < ActiveRecord::Migration
  def change
    create_table :representatives do |t|
      t.string :title
      t.string :name
      t.string :tel
      t.string :fax
      t.string :email

      t.timestamps null: false
    end
  end
end
