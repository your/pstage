class AreaLevel2 < ActiveRecord::Base
  belongs_to :area_level1
  has_many :area_level3s
end
