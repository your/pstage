class AddCategoryToCategorization < ActiveRecord::Migration
  def change
    add_reference :categorizations, :category, index: true, foreign_key: true
  end
end
