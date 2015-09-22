class Category < ActiveRecord::Base
  has_many :categorizations
  has_many :partnerships, :through => :categorizations
  validates :name, presence: true
end
