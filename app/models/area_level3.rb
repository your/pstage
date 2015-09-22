class AreaLevel3 < ActiveRecord::Base
  belongs_to :area_level2s
  has_many :offices
end
