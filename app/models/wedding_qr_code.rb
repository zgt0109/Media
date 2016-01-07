class WeddingQrCode < ActiveRecord::Base
  belongs_to :wedding

  validates_presence_of :content
end
