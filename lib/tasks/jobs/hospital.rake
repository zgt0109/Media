
namespace :hospital do

  desc 'expired hospital doctor arrange items'
  task :expired_hospital_doctor_arrange_items => :environment do
    puts 'Starting expired_hospital_doctor_arrange_items ****** '
    DoctorArrangeItem.need_expires.update_all({:status => DoctorArrangeItem::EXPIRED})
    puts 'Done!'
  end

  desc 'create doctor watches'
  task :create_doctor_watches => :environment do
  	puts "Starting create doctor watches ***********************"
    DoctorArrange.find_each do |a|
      a.create_doctor_watches
    end
  	puts 'Done!'
  end

end
