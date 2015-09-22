class Partner < ActiveRecord::Base
  has_many :partnerships, dependent: :destroy
  has_many :offices, dependent: :destroy
  validates :name, :active, presence: true
end
