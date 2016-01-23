class BookingComment < ActiveRecord::Base
  belongs_to :booking_item
  belongs_to :user
end