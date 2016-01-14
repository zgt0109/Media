class BookingComment < ActiveRecord::Base
  belongs_to :booking_item
end