class Partnership < ActiveRecord::Base
  belongs_to :partner
  belongs_to :office
  has_many :representatives, dependent: :destroy
  validates :partner_id, :office_id, :signing_date, presence: true
end
