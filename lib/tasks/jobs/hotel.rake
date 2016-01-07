
namespace :hotel do

  desc 'created hotel_room_settings'
  task :hotel_room_settings => :environment do
    puts 'Starting create hotel_room_settings ****** will create 31 rows per hotel_room_type!'
    HotelRoomType.normal.find_each do |room_type|
      (Date.today..Date.today+31.days).each do |date|
        room_type.create_hotel_room_settings(date)
      end
    end
    puts 'Done!'
  end

end
