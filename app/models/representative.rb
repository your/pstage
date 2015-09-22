class Representative < ActiveRecord::Base
  belongs_to :partnership
  #attr_accessor :tel, :fax, :email
end
