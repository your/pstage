class Categorization < ActiveRecord::Base
  belongs_to :partnership
  belongs_to :category
  belongs_to :eng_department
end
